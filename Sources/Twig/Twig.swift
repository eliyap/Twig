import Foundation
import OrderedCollections

public struct Twig {
    /// Login callback URL scheme.
    /// Set via the Twitter Developer Portal.
    public static let scheme = "twittersignin"
}

public enum TwigError: Error {
    case invalidURL
    case percentEncodingFailed
    case other(message: String)
    
    /// Indicates the callback URL from `Authorize` was malformed.
    /// https://developer.twitter.com/en/docs/authentication/oauth-1-0a/obtaining-user-access-tokens
    case invalidAuthorizeResponse
}

public enum HTTPMethod: String {
    case GET
    case POST
}

extension URLRequest {
    mutating func setHeaders(_ dict: [String: String]) -> Void {
        for (key, value) in dict {
            setValue(value, forHTTPHeaderField: key)
        }
    }
}
