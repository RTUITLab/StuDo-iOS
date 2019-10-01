//
//  DateFormatterExtension.swift
//  StuDo
//
//  Created by Andrew on 9/2/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

fileprivate let iso8601Dateformat = "yyyy-MM-dd'T'HH:mm:ss"
fileprivate let iso8601DateformatWithNanoseconds = "yyyy-MM-dd'T'HH:mm:ss.SSS"

extension DateFormatter {
    
    static func iso8601StringFromDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = iso8601DateformatWithNanoseconds
        
        return formatter.string(from: date)
    }
    
    static func dateFromISO8601String(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = iso8601Dateformat
        
        var decodedDate: Date!
        if let date = formatter.date(from: dateString) {
            decodedDate = date
        } else {
            formatter.dateFormat = iso8601DateformatWithNanoseconds
            decodedDate = formatter.date(from: dateString)!
        }
        
        // As the time strings stored on the server don't include 'Z' at the end,
        // the date is believed to be in local time and is handled not correctly,
        // since it actually represents GMT Time
        
        // To correct this, offset the decoded time by the difference between
        // time in current time zone and in GMT
        
        let timeOffset = TimeZone.current.secondsFromGMT(for: decodedDate)
        return Calendar.current.date(byAdding: .second, value: Int(timeOffset), to: decodedDate)!

    }
}
