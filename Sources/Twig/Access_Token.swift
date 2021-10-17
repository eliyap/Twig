//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 16/10/21.
//

import Foundation

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

func accessToken(callbackURL: String) async throws -> Void {
    let response = try AuthorizeResponse(callbackURL: callbackURL)
    let parameters: [String: String] = [
        "oauth_token": response.oauth_token,
        "oauth_verifier": response.oauth_verifier,
        "oauth_consumer_key": Keys.consumer,
    ]
    guard let url = URL(string: "https://api.twitter.com/oauth/access_token?\(parameters.parameterString())") else {
        throw TwigError.invalidURL
    }
    var request = URLRequest(url: url)
    request.httpMethod = HTTPMethod.POST.rawValue
    
    let (data, _): (Data, URLResponse) = try await URLSession.shared.data(for: request, delegate: nil)
}
