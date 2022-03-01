//
//  DateFormatterManager.swift
//  GoPushSDK
//
//  Created by Nenad Ljubik on 28.2.22.
//

import Foundation


class DateFormatterManager {
    private static let dateFormatter = DateFormatter()
    
    static func getDateFromStringWith(string: String?, dateFormat: String) -> Date? {
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: string ?? "")
    }
    
    static func getDateStringWithFormat(dateFormat: String, date: Date?) -> String {
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = dateFormat

        if let unwrappedDate = date {
            return dateFormatter.string(from: unwrappedDate)
        } else {
            return ""
        }
    }
}
