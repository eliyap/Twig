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

public func requestToken() async throws -> [String: Any]? {
    guard let url = URL(string: "https://api.twitter.com/oauth/request_token") else {
        throw TwigError.invalidURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = HTTPMethod.POST.rawValue
    
    let (data, response): (Data, URLResponse) = try await URLSession.shared.data(for: request, delegate: nil)
    
    let serial: [String: Any]? = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    
    queryTest()
    
    return serial
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

func oAuth1Signature(
    method: String = HTTPMethod.POST.rawValue,
    url: String,
    parameters: [String: String],
    key: String
) -> String {
    (
        "\(method)"
        + "&\(url.addingPercentEncoding(withAllowedCharacters: .twitter)!)"
        + "&\(parameters.parameterString().addingPercentEncoding(withAllowedCharacters: .twitter)!)"
    ).sha1(with: key)
}

struct OAuth1Signature {
    
    let method: String
    let url: String
    let parameters: [String: String]
    
    init(
        method: String = HTTPMethod.POST.rawValue,
        url: String,
        parameters: [String: String]
    ) {
        self.method = method
        self.url = url
        self.parameters = parameters
    }
    
    /// As described in
    /// Docs: https://developer.twitter.com/en/docs/authentication/oauth-1-0a/creating-a-signature
    var base: String {
        "\(method)"
        + "&\(url.addingPercentEncoding(withAllowedCharacters: .twitter)!)"
        + "&\(parameters.parameterString().addingPercentEncoding(withAllowedCharacters: .twitter)!)"
    }
    
    func signed(with key: String) -> String {
        base.sha1(with: key)
    }
}

extension CharacterSet {
    /// Allowed Characters.
    /// Docs: https://developer.twitter.com/en/docs/authentication/oauth-1-0a/percent-encoding-parameters
    static let twitter: CharacterSet = {
        CharacterSet.alphanumerics.union(["-", ".", "_", "~"])
    }()
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

extension OrderedDictionary where Key: CustomStringConvertible, Value: CustomStringConvertible {
    /// Encode key-value pairs as a parameter string.
    func parameterString() -> String {
        self
            .map{"\($0)=\($1)"}
            .joined(separator: "&")
    }
}
