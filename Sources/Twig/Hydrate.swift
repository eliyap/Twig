//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 17/10/21.
//

import Foundation

func tweets(credentials: OAuthCredentials, ids: [Int]) async throws -> Void {
    var ids = ids
    if ids.count >= 100 {
        Swift.debugPrint("⚠️ WARNING: DISCARDING IDS OVER 100!")
        ids = Array(ids[..<100])
    }
    
    let request = tweetsRequest(credentials: credentials, ids: ids)
    let (data, _) = try await URLSession.shared.data(for: request, delegate: nil)
    
    print(String(data: data, encoding: .ascii))
}

func tweetsRequest(credentials: OAuthCredentials, ids: [Int]) -> URLRequest {
    /// Only 100 tweets may be requested at once.
    /// Docs: https://developer.twitter.com/en/docs/twitter-api/tweets/lookup/api-reference/get-tweets
    precondition(ids.count <= 100, "Too many IDs!")
    
    var tweetsURL = "https://api.twitter.com/2/tweets"
    
    var parameters = signedParameters(method: .GET, url: tweetsURL, credentials: credentials)
    parameters["id"] = ids.map{"\($0)"}.joined(separator: ",")
    
    tweetsURL.append(contentsOf: "?\(parameters.parameterString())")
    let url = URL(string: tweetsURL)!
    return URLRequest(url: url)
}
