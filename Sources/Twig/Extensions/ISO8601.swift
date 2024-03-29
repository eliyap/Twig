//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 24/10/21.
//

import Foundation

/// Source: https://useyourloaf.com/blog/swift-codable-with-custom-dates/
extension DateFormatter {
    static let iso8601withFractionalSeconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    /// For the ISO8601 format string specified at:
    /// https://developer.twitter.com/en/docs/twitter-api/tweets/timelines/api-reference/get-users-id-tweets
    static let iso8601withWholeSeconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    /// Docs:
    /// https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/tweet
    /// > Wed Oct 10 20:19:24 +0000 2018
    static let v1dot1Format: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

extension Date {
    /// Reverse the calling convention.
    func formatted(with formatter: DateFormatter) -> String {
        formatter.string(from: self)
    }
}
