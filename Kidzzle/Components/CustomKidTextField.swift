//
//  CustomKidTextField.swift
//  Kidzzle
//
//  Created by aynnipa on 2/4/2568 BE.
//

import SwiftUI

struct CustomKidTextField: View {
    var title: String
    var placeholder: String
    @Binding var value: String
    var keyboardType: UIKeyboardType = .default
    var sfIcon: String = ""
    
    enum FieldType {
        case fullname
        case congenitialDisease
        case birthWeight
        case bodyLength
        case gender
        case gestationalAge
        case bloodType
        case oxygen
    }
    
    var fieldType: FieldType
    var options: [String] = [] // สำหรับ dropdown
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            switch fieldType {
            case .fullname, .congenitialDisease, .birthWeight, .bodyLength:
                TextField(placeholder, text: $value)
                    .textInputAutocapitalization(fieldType == .fullname ? .words : .none)
                    .keyboardType(getKeyboardType())
                    .padding(.leading, 44)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.jetblack)
                    .background(.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(borderColor(for: value), lineWidth: 1)
                    )
                
            case .gender, .gestationalAge, .bloodType, .oxygen:
                Menu {
                    ForEach(options, id: \.self) { option in
                        Button(option) {
                            value = option
                        }
                    }
                } label: {
                    HStack {
                        Text(value.isEmpty ? placeholder : value)
                            .foregroundColor(value.isEmpty ? .gray : .black)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .frame(height: 44)
                    .padding(.horizontal)
                    .background(.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
        .overlay(alignment: .leadingFirstTextBaseline) {
            if !sfIcon.isEmpty {
                Image(systemName: sfIcon)
                    .foregroundStyle(.jetblack)
                    .frame(width: 24)
                    .padding(.horizontal, 8)
            }
        }
    }
    
    private func getKeyboardType() -> UIKeyboardType {
        switch fieldType {
        case .birthWeight, .bodyLength:
            return .decimalPad
        default:
            return keyboardType
        }
    }
    
    private func borderColor(for value: String) -> Color {
        if value.isEmpty {
            return Color.gray.opacity(0.3)
        }
        return .blue
    }
}
