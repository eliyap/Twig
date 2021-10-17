//
//  SignatureGut.swift
//  Branch
//
//  Created by Secret Asian Man Dev on 17/10/21.
//

import Foundation
import OrderedCollections

// MARK: - OAuth Guts
internal func oAuth1Signature(
    method: String = HTTPMethod.POST.rawValue,
    url: String,
    parameters: [String: String],
    consumerSecret: String,
    oauthSecret: String
) -> String {
    (
        "\(method)"
        + "&\(url.addingPercentEncoding(withAllowedCharacters: .twitter)!)"
        + "&\(parameters.parameterString().addingPercentEncoding(withAllowedCharacters: .twitter)!)"
    ).sha1(with: consumerSecret + "&" + oauthSecret)
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

internal extension Dictionary where Key == String, Value == String {
    /// Header string as described in
    /// Docs: https://developer.twitter.com/en/docs/authentication/oauth-1-0a/authorizing-a-request
    func headerString() -> String {
        self
            .map { "\($0)=\"\($1.addingPercentEncoding(withAllowedCharacters: .twitter)!)\"" }
            .joined(separator: ", ")
    }
}
