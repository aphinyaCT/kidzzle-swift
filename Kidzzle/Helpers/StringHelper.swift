//
//  StringHelper.swift
//  Kidzzle
//
//  Created by aynnipa on 13/4/2568 BE.
//

import Foundation

struct StringHelper {
    
    static func cleanHtmlText(_ text: String) -> String {
        var result = text
        
        // แทนที่ &nbsp; ด้วยช่องว่าง
        result = result.replacingOccurrences(of: "&nbsp;", with: " ")
        
        // ลบแท็ก <p> และ </p>
        result = result.replacingOccurrences(of: "<p>", with: "")
        result = result.replacingOccurrences(of: "</p>", with: " ")
        
        // ลบแท็ก <br> และ <br/>
        result = result.replacingOccurrences(of: "<br>", with: " ")
        result = result.replacingOccurrences(of: "<br/>", with: " ")
        
        // ลบแท็ก <strong> และ </strong>
        result = result.replacingOccurrences(of: "<strong>", with: "")
        result = result.replacingOccurrences(of: "</strong>", with: "")
        
        // ลบช่องว่างที่มากเกินไป
        result = result.replacingOccurrences(of: "  ", with: " ")
        
        // ตัดช่องว่างที่หัวและท้าย
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return result
    }
    
    static func removeParenthesesContent(from text: String) -> String {
        if let range = text.range(of: #" *\([^)]*\)"#, options: .regularExpression) {
            return text.replacingCharacters(in: range, with: "").trimmingCharacters(in: .whitespaces)
        }
        return text
    }
}
