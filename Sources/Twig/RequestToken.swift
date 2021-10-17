//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 16/10/21.
//

import Foundation

public struct OAuthRequestCredentials {
    public let oauth_token: String
    public let oauth_token_secret: String
    public let oauth_callback_confirmed: Bool
    
    /**
     Decode OAuth Tokens from a parameter string like
     `"oauth_token=xyz&oauth_token_secret=abc&oauth_callback_confirmed=true"`
     */
    init?(_ data: Data) {
        guard let string = String(bytes: data, encoding: .ascii) else { return nil }
        let pairs = string.split(separator: "&")
        guard pairs.count >= 3 else { return nil }
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
            let oauth_callback_confirmed = dict["oauth_callback_confirmed"]
        else { return nil }
        
        self.oauth_token = oauth_token
        self.oauth_token_secret = oauth_token_secret
        switch oauth_callback_confirmed {
        case "true":
            self.oauth_callback_confirmed = true
        case "false":
            self.oauth_callback_confirmed = false
        default:
            return nil
        }
    }
}

public func requestToken() async throws -> OAuthRequestCredentials? {
    var tokenURL = "https://api.twitter.com/oauth/request_token"
    
    /// Parameters for an authorization request.
    /// Docs: https://developer.twitter.com/en/docs/authentication/oauth-1-0a/authorizing-a-request
    var parameters: [String: String] = [
        "oauth_consumer_key": Keys.consumer,
        "oauth_nonce": nonce(),
        "oauth_signature_method": "HMAC-SHA1",
        "oauth_timestamp": "\(Int(Date().timeIntervalSince1970))",
        "oauth_version": "1.0",
    ]
    
    /// Add cryptographic signature.
    let signature = oAuth1Signature(
        method: HTTPMethod.POST.rawValue,
        url: tokenURL,
        parameters: parameters,
        consumerSecret: Keys.consumer_secret,
        oauthSecret: ""
    )
    parameters["oauth_signature"] = signature
    
    /// Add parameters in query string.
    tokenURL.append(contentsOf: "?\(parameters.parameterString())")
    
    guard let url = URL(string: tokenURL) else {
        throw TwigError.invalidURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = HTTPMethod.POST.rawValue
    
    let (data, _): (Data, URLResponse) = try await URLSession.shared.data(for: request, delegate: nil)
    
    return OAuthRequestCredentials(data)
}

