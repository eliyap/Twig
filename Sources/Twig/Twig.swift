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
