import Foundation
import Combine

internal struct RawFollowingResponse: Decodable {
    let data: [RawIncludeUser]
    let meta: Meta
    
    /// With apologies to Mark Zuckerberg.
    internal struct Meta: Decodable {
        /// Pagination token for the next page of results.
        let next_token: String?
    }
}

/// Get all users this user follows.
public func requestFollowing(credentials: OAuthCredentials) async throws -> Set<RawIncludeUser> {
    let decoder = JSONDecoder()
    var users = Set<RawIncludeUser>()

    /// Fetch until API returns no token, indicating last page.
    var paginationToken: String? = nil
    repeat {
        let request = follwingRequest(credentials: credentials, paginationToken: paginationToken)
        let (data, _): (Data, URLResponse) = try await URLSession.shared.data(for: request, delegate: nil)
        let items = try decoder.decode(RawFollowingResponse.self, from: data)
        users.formUnion(items.data)
        paginationToken = items.meta.next_token
    } while (paginationToken != nil)
     
    return users
}

/// Docs: https://developer.twitter.com/en/docs/twitter-api/users/follows/api-reference/get-users-id-following
/// - Note: Query string authorization did not work. Use header instead.
/// - Note: Ordering is very particular. Formulate the signature with no parameter string, then append the parameters after.
internal func follwingRequest(credentials: OAuthCredentials, paginationToken: String?) -> URLRequest {
    
    /// Request maximum page size of 1000.
    var additional = ["max_results": "1000"]
    if let paginationToken = paginationToken {
        additional["pagination_token"] = paginationToken
    }
    
    /// Formulate request.
    var followingURL = "https://api.twitter.com/2/users/\(credentials.user_id)/following"
    let parameters = signedParameters(method: .GET, url: followingURL, credentials: credentials, including: additional)
    followingURL.append(contentsOf: "?\(additional.parameterString())")
    
    let url = URL(string: followingURL)!
    var request = URLRequest(url: url)
    request.httpMethod = HTTPMethod.GET.rawValue
    request.setValue("OAuth \(parameters.headerString())", forHTTPHeaderField: "authorization")
    
    return request
}
