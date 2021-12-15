//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 14/12/21.
//

import Foundation

/// Set of parameters to be attached to Twitter API Requests.
internal struct RequestParameters {
    /// Parameters that should be percent encoded.
    var encodable: [String?]
    
    /// Parameters that should **not** be percent encoded.
    var nonEncodable: [String?]
    
    init(
        encodable: [String?] = [],
        nonEncodable: [String?] = []
    ) {
        self.encodable = encodable
        self.nonEncodable = nonEncodable
    }
}
