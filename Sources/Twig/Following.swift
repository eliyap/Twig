import Foundation

public func requestFollowing(credentials: OAuthCredentials) async throws -> Void {
    let request = follwingRequest(credentials: credentials)
    let (data, response): (Data, URLResponse) = try await URLSession.shared.data(for: request, delegate: nil)
    let json = try JSONSerialization.jsonObject(with: data, options: [])
    print(json)
}

internal func follwingRequest(credentials: OAuthCredentials) -> URLRequest {
    /// Formulate request.
    let followingURL = "https://api.twitter.com/2/users/\(credentials.user_id)/following"
    let url = URL(string: followingURL)!
    var request = URLRequest(url: url)
    request.httpMethod = HTTPMethod.GET.rawValue

    /// - Note: Query string authorization did not work. Use header instead.
    let parameters = signedParameters(method: .GET, url: followingURL, credentials: credentials)
    request.setValue("OAuth \(parameters.headerString())", forHTTPHeaderField: "authorization")
    
    return request
}
