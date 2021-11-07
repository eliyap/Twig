import Foundation

public func requestFollowing(credentials: OAuthCredentials) async throws -> Void {
    let request = follwingRequest(credentials: credentials)
    let (data, response): (Data, URLResponse) = try await URLSession.shared.data(for: request, delegate: nil)
    let json = try JSONSerialization.jsonObject(with: data, options: [])
    print(json)
}

/// Docs: https://developer.twitter.com/en/docs/twitter-api/users/follows/api-reference/get-users-id-following
internal func follwingRequest(credentials: OAuthCredentials) -> URLRequest {
    let additional = ["max_results": "10"]
//    let additional: [String: String] = [:]
    /// Formulate request.
    var followingURL = "https://api.twitter.com/2/users/\(credentials.user_id)/following"
    
    /// - Note: Query string authorization did not work. Use header instead.
    let parameters = signedParameters(method: .GET, url: followingURL, credentials: credentials, including: additional)
    
    followingURL.append(contentsOf: "?\(additional.parameterString())")
    
    let url = URL(string: followingURL)!
    var request = URLRequest(url: url)
    request.httpMethod = HTTPMethod.GET.rawValue
    request.setValue("OAuth \(parameters.headerString())", forHTTPHeaderField: "authorization")
    
    return request
}
