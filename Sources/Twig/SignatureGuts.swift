//
//  SignatureGut.swift
//  Branch
//
//  Created by Secret Asian Man Dev on 17/10/21.
//

import Foundation
import OrderedCollections

/// Allows for missing credentials, as when hitting `request_token` endpoint.
/// - Parameters:
///   - method: ``HTTPMethod`` being used for the reqest.
///   - url: Base URL string.
///   - credentials: User's ``OAuthCredentials``, if any.
///   - additionalParameters: additional parameters to add for signing.
/// - Returns: signed dictionary for authentication.
func signedParameters(
    method: HTTPMethod,
    url: String,
    credentials: OAuthCredentials?,
    including additionalParameters: [String: String] = [:]
) -> [String: String] {
    /// OAuth 1.0 Authroization Parameters.
    /// Docs: https://developer.twitter.com/en/docs/authentication/oauth-1-0a/authorizing-a-request
    var parameters: [String: String] = [
        "oauth_consumer_key": Keys.consumer,
        "oauth_nonce": nonce(),
        "oauth_signature_method": "HMAC-SHA1",
        "oauth_timestamp": "\(Int(Date().timeIntervalSince1970))",
        "oauth_version": "1.0",
    ].merging(additionalParameters, uniquingKeysWith: {(curr, _) in curr})
    
    if let credentials = credentials {
        parameters["oauth_token"] = credentials.oauth_token
    }
    
    /// Add cryptographic signature.
    let signature = oAuth1Signature(
        method: method,
        url: url,
        parameters: parameters,
        consumerSecret: Keys.consumer_secret,
        /**
         > ...where the token secret is not yet known ... the signing key should consist of
         > the percent encoded consumer secret followed by an ampersand character ‘&’.
         – https://developer.twitter.com/en/docs/authentication/oauth-1-0a/creating-a-signature
         */
        oauthSecret: credentials?.oauth_token_secret ?? ""
    )
    parameters["oauth_signature"] = signature
    
    return parameters
}

// MARK: - OAuth Guts
internal func oAuth1Signature(
    method: HTTPMethod,
    url: String,
    parameters: [String: String],
    consumerSecret: String,
    oauthSecret: String
) -> String {
    let queryString = parameters
        .encodedSortedParameterString()
        .addingPercentEncoding(withAllowedCharacters: .twitter)!
    return (
        method.rawValue
        + "&\(url.addingPercentEncoding(withAllowedCharacters: .twitter)!)"
        /// > Make sure to percent encode the parameter string.
        /// Docs: https://developer.twitter.com/en/docs/authentication/oauth-1-0a/creating-a-signature
        + "&\(queryString)"
    ).sha1(with: consumerSecret + "&" + oauthSecret)
    /**
     > ...where the token secret is not yet known ... the signing key should consist of
     > the percent encoded consumer secret followed by an ampersand character ‘&’.
     – https://developer.twitter.com/en/docs/authentication/oauth-1-0a/creating-a-signature
     */
}

internal extension Dictionary where Key == String, Value == String {
    func encodedSortedParameterString() -> String {
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

internal extension Dictionary where Key == String, Value == String {
    /// Header string as described in
    /// Docs: https://developer.twitter.com/en/docs/authentication/oauth-1-0a/authorizing-a-request
    func headerString() -> String {
        self
            .map { "\($0)=\"\($1.addingPercentEncoding(withAllowedCharacters: .twitter)!)\"" }
            .joined(separator: ", ")
    }
}
