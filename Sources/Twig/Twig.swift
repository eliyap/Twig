import Foundation
import OrderedCollections

public struct Twig {
    public private(set) var text = "Hello, World!"

    public init() {
    }
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

public struct OAuthCredentials {
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
        guard pairs.count == 3 else { return nil }
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

public func requestToken() async throws -> OAuthCredentials? {
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
    let signature = oAuth1Signature(url: tokenURL, parameters: parameters, key: Keys.consumer_secret)
    parameters["oauth_signature"] = signature
    
    tokenURL.append(contentsOf: "?\(parameters.parameterString())")
    
    guard let url = URL(string: tokenURL) else {
        throw TwigError.invalidURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = HTTPMethod.POST.rawValue
    
    let (data, response): (Data, URLResponse) = try await URLSession.shared.data(for: request, delegate: nil)
    
    return OAuthCredentials(data)
}

extension URLRequest {
    mutating func setHeaders(_ dict: [String: String]) -> Void {
        for (key, value) in dict {
            setValue(value, forHTTPHeaderField: key)
        }
    }
}

func queryTest() -> Void {
//    let example: [String: String] = [
//        "oauth_consumer_key": "rBc4q2NVhhslfymUO0JM5L1z3",
//        "oauth_nonce": "3b9yH8kTFhZ",
//        "oauth_signature_method": "HMAC-SHA1",
//        "oauth_timestamp": "1634356377",
//        "oauth_version": "1.0",
//    ]
    let example: [String: String] = [
        "include_entities": "true",
        "oauth_consumer_key": "xvz1evFS4wEEPTGEFPHBog",
        "oauth_nonce": "kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg",
        "oauth_signature_method": "HMAC-SHA1",
        "oauth_timestamp": "1318622958",
        "oauth_token": "370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb",
        "oauth_version": "1.0",
        "status": "Hello Ladies + Gentlemen, a signed OAuth request!",
    ]
//    let consumer_secret = "JriQ7iqCshuWdYmDytyw1UpjOvOYhueyFvqDaxOOSRy94s4xBD"
    let consumer_secret = "kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw&LswwdoUaIvS8ltyTt5jkRh4J50vUPVVHtR2YPi5kE"
    
    let sig = oAuth1Signature(
        url: "https://api.twitter.com/1.1/statuses/update.json",
        parameters: example,
        key: consumer_secret
    )
    
    print(sig)
}

func headerTest() -> Void {
    let example = [
        "oauth_consumer_key": "xvz1evFS4wEEPTGEFPHBog",
        "oauth_nonce": "kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg",
        "oauth_signature": "tnnArxj06cWHq44gCs1OSKk%2FjLY%3D",
        "oauth_signature_method": "HMAC-SHA1",
        "oauth_timestamp": "1318622958",
        "oauth_token": "370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb",
        "oauth_version": "1.0"
    ]
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
