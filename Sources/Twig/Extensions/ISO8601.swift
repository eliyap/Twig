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
}
