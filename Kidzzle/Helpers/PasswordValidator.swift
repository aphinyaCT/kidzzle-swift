//
//  PasswordValidator.swift
//  Kidzzle
//
//  Created by aynnipa on 4/3/2568 BE.
//

import SwiftUI

struct PasswordValidator: View {
    @Binding var password: String
    
    private var hasMinimumLength: Bool {
        password.count >= 8
    }
    
    private var hasUppercase: Bool {
        password.contains { $0.isUppercase }
    }
    
    private var hasLowercase: Bool {
        password.contains { $0.isLowercase }
    }
    
    private var hasDigit: Bool {
        password.contains { $0.isNumber }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            PasswordRequirementRow(text: "อย่างน้อย 8 ตัวอักษร", isMet: hasMinimumLength)
            PasswordRequirementRow(text: "มีตัวอักษร A-Z พิมพ์ใหญ่", isMet: hasUppercase)
            PasswordRequirementRow(text: "มีตัวอักษร A-Z พิมพ์เล็ก", isMet: hasLowercase)
            PasswordRequirementRow(text: "มีตัวเลข 0-9", isMet: hasDigit)
        }
        .padding(.vertical, 6)
    }
}

struct PasswordRequirementRow: View {
    var text: String
    var isMet: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isMet ? .greenMint : .gray)
            
            Text(text)
                .foregroundColor(isMet ? .jetblack : .gray)
                .font(customFont(type: .regular, textStyle: .footnote))
        }
    }
}
