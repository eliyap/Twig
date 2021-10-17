//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 16/10/21.
//

import Foundation
import OrderedCollections

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
        "oauth_nonce": UUID().uuidString.replacingOccurrences(of: "-", with: ""),
        "oauth_signature_method": "HMAC-SHA1",
        "oauth_timestamp": "\(Int(Date().timeIntervalSince1970))",
        "oauth_version": "1.0",
    ]
    
    /// Add cryptographic signature.
    let signature = oAuth1Signature(url: tokenURL, parameters: parameters, key: Keys.consumer_secret)
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

// MARK: - OAuth Guts
fileprivate func oAuth1Signature(
    method: String = HTTPMethod.POST.rawValue,
    url: String,
    parameters: [String: String],
    key: String
) -> String {
    (
        "\(method)"
        + "&\(url.addingPercentEncoding(withAllowedCharacters: .twitter)!)"
        + "&\(parameters.parameterString().addingPercentEncoding(withAllowedCharacters: .twitter)!)"
    ).sha1(with: key + "&")
    /**
     > ...where the token secret is not yet known ... the signing key should consist of
     > the percent encoded consumer secret followed by an ampersand character ‘&’.
     – https://developer.twitter.com/en/docs/authentication/oauth-1-0a/creating-a-signature
     */
}

internal extension Dictionary where Key == String, Value == String {
    func parameterString() -> String {
        self
            .unsafePercentEncoded()
            .keySorted()
            .parameterString()
    }
    
    /// - Note: this uses a force unwrap, only use values where `addingPercentEncoding` will succeed.
    func unsafePercentEncoded() -> [String: String] {
        var result = [String: String]()
        for (key, value) in self {
            /// Permit `urlQueryAllowed` characters, from: https://developer.apple.com/documentation/foundation/nscharacterset/1416698-urlqueryallowed
            /// - Note: this uses a force unwrap
            let pctKey = key.addingPercentEncoding(withAllowedCharacters: .twitter)!
            let pctValue = value.addingPercentEncoding(withAllowedCharacters: .twitter)!
            result[pctKey] = pctValue
        }
        return result
    }
    
    func keySorted() -> OrderedDictionary<String, String> {
        var result = OrderedDictionary<String, String>()
        for (key, value) in self {
            result[key] = value
        }
        result.sort(by: {$0.key < $1.key})
        return result
    }
}

fileprivate extension OrderedDictionary where Key: CustomStringConvertible, Value: CustomStringConvertible {
    /// Encode key-value pairs as a parameter string.
    func parameterString() -> String {
        self
            .map{"\($0)=\($1)"}
            .joined(separator: "&")
    }
}

fileprivate extension Dictionary where Key == String, Value == String {
    /// Header string as described in
    /// Docs: https://developer.twitter.com/en/docs/authentication/oauth-1-0a/authorizing-a-request
    func headerString() -> String {
        self
            .map { "\($0)=\"\($1.addingPercentEncoding(withAllowedCharacters: .twitter)!)\"" }
            .joined(separator: ", ")
    }
}
