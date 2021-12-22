//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 16/10/21.
//

import Foundation

/// Fetch the OAuth access token from Twitter, using the callbar URL provided after the user logs in on their phone.
///
/// Completes "Step 3: POST `oauth/access_token`" as outlined below:
/// https://developer.twitter.com/en/docs/authentication/oauth-1-0a/obtaining-user-access-tokens
///
/// Endpoint documentation: https://developer.twitter.com/en/docs/authentication/api-reference/access_token
public func accessToken(callbackURL: String) async throws -> OAuthCredentials {
    let response = try AuthorizeResponse(callbackURL: callbackURL)
    let parameters: [String: String] = [
        "oauth_token": response.oauth_token,
        "oauth_verifier": response.oauth_verifier,
        "oauth_consumer_key": Keys.consumer,
    ]
    guard let url = URL(string: "https://api.twitter.com/oauth/access_token?\(parameters.encodedSortedParameterString())") else {
        throw TwigError.invalidURL
    }
    var request = URLRequest(url: url)
    request.httpMethod = HTTPMethod.POST.rawValue
    
    let (data, _): (Data, URLResponse) = try await URLSession.shared.data(for: request, delegate: nil)
    
    if let credentials = parseCredentials(from: data) {
        return credentials
    } else {
        throw TwigError.invalidRequestResponse
    }
}

/// Parses an example response from endpoint:
/// https://developer.twitter.com/en/docs/authentication/api-reference/access_token
///
/// Example response: (whitespace added for readability)
/// ```
///  oauth_token=62532xx-eWudHldSbIaelX7swmsiHImEL4KinwaGloxxxxxx
/// &oauth_token_secret=2EEfA6BG5ly3sR3XjE0IBSnlQu4ZrUzPiYxxxxxx
/// &user_id=6253282
/// &screen_name=twitterapi
/// ```
fileprivate func parseCredentials(from data: Data) -> OAuthCredentials? {
    guard let string = String(bytes: data, encoding: .ascii) else { return nil }
    let pairs = string.split(separator: "&")
    guard pairs.count >= 4 else { return nil }
    var dict = [String: String]()
    for pair in pairs {
        let components = pair.split(separator: "=")
        guard components.count == 2 else { return nil }
        let (key, value) = (String(components[0]), String(components[1]))
        dict[key] = value
    }
    
    guard
        let oauth_token = dict["oauth_token"],
        let oauth_token_secret = dict["oauth_token_secret"],
        let user_id_string = dict["user_id"],
        let user_id = Int(user_id_string),
        let screen_name = dict["screen_name"]
    else { return nil }
    
    return OAuthCredentials(
        oauth_token: oauth_token,
        oauth_token_secret: oauth_token_secret,
        user_id: user_id,
        screen_name: screen_name
    )
}

// MARK: - Guts
/// https://developer.twitter.com/en/docs/authentication/oauth-1-0a/obtaining-user-access-tokens
fileprivate struct AuthorizeResponse {
    
    let oauth_token: String
    let oauth_verifier: String
    
    init(callbackURL: String) throws {
        /// Extract parameter string.
        guard callbackURL.starts(with: "twittersignin://") else { throw TwigError.invalidAuthorizeResponse }
        let q = callbackURL.split(separator: "?")
        guard q.count == 2 else { throw TwigError.invalidAuthorizeResponse }
        let parameterString = q[1]
        
        /// Extract parameters.
        var parameters = [String: String]()
        let parameterPairs = parameterString.split(separator: "&")
        for pair in parameterPairs {
            let components = pair.split(separator: "=")
            guard components.count == 2 else { throw TwigError.invalidAuthorizeResponse }
            let (key, value) = (String(components[0]), String(components[1]))
            parameters[key] = value
        }
        
        guard
            let oauth_token = parameters["oauth_token"],
            let oauth_verifier = parameters["oauth_verifier"]
        else { throw TwigError.invalidAuthorizeResponse }
        
        self.oauth_token = oauth_token
        self.oauth_verifier = oauth_verifier
    }
}
