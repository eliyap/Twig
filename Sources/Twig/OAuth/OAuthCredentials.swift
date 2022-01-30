//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 16/10/21.
//

import Foundation

public struct OAuthCredentials: Sendable {
    public let oauth_token: String
    public let oauth_token_secret: String
    public let user_id: Int
    public let screen_name: String
}

extension OAuthCredentials: Codable {
    /// Automagical!
}
