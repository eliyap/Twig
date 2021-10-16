//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 16/10/21.
//

import Foundation

extension CharacterSet {
    /// Allowed Characters.
    /// Docs: https://developer.twitter.com/en/docs/authentication/oauth-1-0a/percent-encoding-parameters
    static let twitter: CharacterSet = {
        CharacterSet.alphanumerics.union(["-", ".", "_", "~"])
    }()
}
