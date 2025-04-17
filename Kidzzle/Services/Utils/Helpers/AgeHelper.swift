//
//  AgeHelper.swift
//  Kidzzle
//
//  Created by aynnipa on 12/4/2568 BE.
//

import Foundation

struct AgeHelper {
    
    static func calculateAge(from birthday: Date) -> String {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day], from: birthday, to: now)
        
        guard let years = components.year, let months = components.month, let days = components.day else {
            return "ไม่สามารถคำนวณอายุได้"
        }
        
        if years == 0 {
            return "\(months) เดือน \(days) วัน"
        } else {
            return "\(years) ปี \(months) เดือน \(days) วัน"
        }
    }

    static func formatAge(from dateString: String?) -> String {
        guard let dateString = dateString else { return "ไม่ทราบวันเกิด" }

        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.calendar = Calendar(identifier: .gregorian) // ใช้เฉพาะค.ศ. อย่างเดียว
        
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd",
            "dd/MM/yyyy", // ถ้าใส่มาแบบนี้ ก็จะอ่านเป็น ค.ศ. เช่น 12/04/2025
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        ]
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                let ageString = calculateAge(from: date)
                return "อายุ \(ageString)"
            }
        }

        return "ไม่สามารถแปลงวันเกิดได้"
    }
    
    static func calculateAgeAtAssessment(from birthday: Date, to assessmentDate: Date) -> (years: Int, months: Int, days: Int) {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year, .month, .day], from: birthday, to: assessmentDate)
        
        let years = ageComponents.year ?? 0
        let months = ageComponents.month ?? 0
        let days = ageComponents.day ?? 0
        
        return (
            years: max(0, years),
            months: max(0, months),
            days: max(0, days)
        )
    }

    static func formatAgeAtAssessment(from birthday: Date, to assessmentDate: Date) -> String {
        let age = calculateAgeAtAssessment(from: birthday, to: assessmentDate)
        
        if age.years == 0 {
            return "\(age.months) เดือน \(age.days) วัน"
        } else {
            return "\(age.years) ปี \(age.months) เดือน \(age.days) วัน"
        }
    }
}
