//
//  DateHelper.swift
//  Kidzzle
//
//  Created by aynnipa on 7/4/2568 BE.
//

import Foundation

public extension String {
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression) != nil
    }
}

public extension String {
    func normalizeDateFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_US")
        
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ssZ",           // ISO 8601
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",       // ISO 8601 with milliseconds
            "yyyy-MM-dd",                       // Basic format
            "dd MM yyyy",                       // e.g., 14 04 2025
            "yyyy/MM/dd",                       // e.g., 2025/04/14
            "dd-MM-yyyy",                       // e.g., 14-04-2025
            "dd/MM/yyyy",                       // e.g., 14/04/2025 (already final format, but useful to handle fallback)
            "yyyy.MM.dd G 'at' HH:mm:ss zzz",   // e.g., 2025.04.14 AD at 10:12:34 PDT
            "EEE MMM dd HH:mm:ss Z yyyy"        // e.g., Mon Apr 14 10:12:34 +0000 2025 (macOS default `.description`)
        ]
        
        for format in formats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: self) {
                dateFormatter.dateFormat = "dd/MM/yyyy"
                return dateFormatter.string(from: date)
            }
        }
        
        return self
    }
    
    func toServerDateFormat() -> String {
        if self.matches("^\\d{4}-\\d{2}-\\d{2}$") {
            return self
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_US")
        
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "dd MMM yyyy",
            "dd/MM/yyyy"
        ]
        
        for format in formats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: self) {
                dateFormatter.dateFormat = "yyyy-MM-dd"
                return dateFormatter.string(from: date)
            }
        }
        
        return self
    }
    
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_US")
        
        let formats = [
            "yyyy-MM-dd",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "dd MMM yyyy",
            "dd/MM/yyyy"
        ]
        
        for format in formats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: self) {
                return date
            }
        }
        
        return nil
    }

        func parseDate() -> Date {
            let dateFormatters: [DateFormatter] = [
                { () -> DateFormatter in
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.timeZone = TimeZone(abbreviation: "ICT")
                    return formatter
                }()
            ]
            
            for formatter in dateFormatters {
                if let date = formatter.date(from: self) {
                    var calendar = Calendar(identifier: .gregorian)
                    calendar.timeZone = TimeZone(abbreviation: "ICT") ?? .current
                    
                    let components = calendar.dateComponents([.year, .month, .day], from: date)
                    
                    if let adjustedDate = calendar.date(from: components) {
                        print("✅ Successfully parsed date: \(self) -> \(adjustedDate)")
                        return adjustedDate
                    }
                }
            }
            
            print("❌ Failed to parse date: \(self)")
            return Date()
        }
}

extension Date {
   func currentDateString() -> String {
       let dateFormatter = DateFormatter()
       dateFormatter.locale = Locale(identifier: "en_US")
       dateFormatter.dateFormat = "dd/MM/yyyy"
       
       return dateFormatter.string(from: self)
   }
}
