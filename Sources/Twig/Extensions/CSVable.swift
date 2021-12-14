//
//  CSVable.swift
//  
//
//  Created by Secret Asian Man Dev on 14/12/21.
//

import Foundation

protocol CSVable: RawRepresentable { /* no requirements */ }
extension Collection where Element: CSVable {
    var csv: String {
        map{"\($0.rawValue)"}.joined(separator: ",")
    }
}

extension TweetExpansion: CSVable { }
extension MediaField: CSVable { }
extension TweetField: CSVable { }
