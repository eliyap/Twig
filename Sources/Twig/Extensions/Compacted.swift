//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 14/12/21.
//

import Foundation

extension Dictionary where Value == Optional<String> {
    var compacted: [Key: String] {
        var result = [Key: String]()
        forEach { (k, v) in
            if let v = v {
                result[k] = v
            }
        }
        return result
    }
}
