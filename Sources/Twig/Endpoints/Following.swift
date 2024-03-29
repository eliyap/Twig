import Foundation
import Combine

/// Shell enum for information about the "Following" endpoint.
public enum FollowingEndpoint {
    /** Fetches are limited to ~1/min. Therefore, only declare data stale after 90s.
        Docs: https://developer.twitter.com/en/docs/twitter-api/users/follows/api-reference/get-users-id-following
     
        Computed to work around generic-stored error.
     */
    public static var staleTimer: TimeInterval { 90 }
    
    internal struct Response: Decodable {
        /// Data is `nil` when the user does not follow anyone.
        let data: [RawUser]?
        
        let meta: Meta
        
        /// With apologies to Mark Zuckerberg.
        internal struct Meta: Decodable {
            /// Pagination token for the next page of results.
            let next_token: String?
        }
    }
}

/// Get all users this user follows.
public func requestFollowing(credentials: OAuthCredentials) async throws -> Set<RawUser> {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(.iso8601withFractionalSeconds)
    var users = Set<RawUser>()

    /// Fetch until API returns no token, indicating last page.
    var paginationToken: String? = nil
    repeat {
        let request = follwingRequest(credentials: credentials, paginationToken: paginationToken)
        let (data, response): (Data, URLResponse) = try await URLSession.shared.data(for: request, delegate: nil)
        
        if let response = response as? HTTPURLResponse {
            if 200..<300 ~= response.statusCode { /* ok! */ }
            else {
                let dict: [String: Any]? = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
                TwigLog.error("""
                    \(#function) returned with bad status code
                    - code: \(response.statusCode)
                    - dict: \(dict as Any)
                    """)
                throw TwigError.badStatusCode(code: response.statusCode)
            }
        }
        
        let items = try decoder.decode(FollowingEndpoint.Response.self, from: data)
        
        /// - Note: `data` is `nil` when user does not follow anyone.
        users.formUnion(items.data ?? [])
        
        paginationToken = items.meta.next_token
    } while (paginationToken != nil)
     
    return users
}

/// Docs: https://developer.twitter.com/en/docs/twitter-api/users/follows/api-reference/get-users-id-following
/// - Note: Query string authorization did not work. Use header instead.
/// - Note: Ordering is very particular. Formulate the signature with no parameter string, then append the parameters after.
internal func follwingRequest(credentials: OAuthCredentials, paginationToken: String?) -> URLRequest {
    authorizedRequest(
        endpoint: "https://api.twitter.com/2/users/\(credentials.user_id)/following",
        method: .GET,
        credentials: credentials,
        parameters: RequestParameters(
            encodable: [
                UserField.queryKey: UserField.common.csv,
            ],
            nonEncodable: [
                /// Request maximum page size of 1000.
                "max_results": "1000",
                "pagination_token": paginationToken,
            ]
        )
    )
}
