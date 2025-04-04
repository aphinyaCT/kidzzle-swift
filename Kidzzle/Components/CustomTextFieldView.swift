////
////  CustomTextFieldView.swift
////  Kidzzle
////
////  Created by aynnipa on 1/3/2568 BE.
////
//
//import SwiftUI
//
//struct CustomTextFieldView: View {
//    var sfIcon: String
//    var iconTint: Color
//    var hint: String
//    var isPassword: Bool = false
//    var isEmail: Bool = false
//    @Binding var value: String
//    @State private var showPassword: Bool = false
//    
//    var body: some View {
//        HStack (alignment: .top, spacing: 8) {
//            VStack (alignment: .leading, spacing: 8) {
//                if isPassword {
//                    Group {
//                        if showPassword {
//                            TextField(hint, text: $value)
//                                .onChange(of: value) { _, newValue in
//                                    value = filterPasswordInput(newValue)
//                                }
//                                .padding(.leading, 44)
//                                .frame(height: 44)
//                                .frame(maxWidth: .infinity)
//                                .foregroundColor(.jetblack)
//                                .background(.white)
//                                .cornerRadius(10)
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .stroke(borderColor(for: value, isPassword: true), lineWidth: 1)
//                                )
//                        } else {
//                            SecureField(hint, text: $value)
//                                .onChange(of: value) { _, newValue in
//                                    value = filterPasswordInput(newValue)
//                                }
//                                .padding(.leading, 44)
//                                .frame(height: 44)
//                                .frame(maxWidth: .infinity)
//                                .foregroundColor(.jetblack)
//                                .background(.white)
//                                .cornerRadius(10)
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .stroke(borderColor(for: value, isPassword: true), lineWidth: 1)
//                                )
//                        }
//                    }
//                } else if isEmail {
//                    TextField(hint, text: $value)
//                        .textInputAutocapitalization(.never)
//                        .keyboardType(.emailAddress)
//                        .onChange(of: value) { _, newValue in
//                            value = filterEmailInput(newValue)
//                        }
//                        .padding(.leading, 44)
//                        .frame(height: 44)
//                        .frame(maxWidth: .infinity)
//                        .foregroundColor(.jetblack)
//                        .background(.white)
//                        .cornerRadius(10)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(borderColor(for: value, isEmail: true), lineWidth: 1)
//                        )
//                } else {
//                    TextField(hint, text: $value)
//                        .padding(.leading, 44)
//                        .frame(height: 44)
//                        .frame(maxWidth: .infinity)
//                        .foregroundColor(.jetblack)
//                        .background(.white)
//                        .cornerRadius(10)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(borderColor(for: value), lineWidth: 1)
//                        )
//                }
//            }
//            .font(customFont(type: .regular, textStyle: .callout))
//            .overlay(alignment: .leadingFirstTextBaseline) {
//                Image(systemName: sfIcon)
//                    .foregroundStyle(iconTint)
//                    .frame(width: 24)
//                    .padding(.horizontal, 8)
//            }
//            .overlay(alignment: .trailing) {
//                if isPassword {
//                    Button(action: {
//                        withAnimation {
//                            showPassword.toggle()
//                        }
//                    }, label: {
//                        Image(systemName: showPassword ? "eye.slash" : "eye")
//                            .foregroundStyle(.jetblack)
//                            .padding(10)
//                            .contentShape(.rect)
//                    })
//                }
//            }
//        }
//    }
//    
//    private func isValidPassword(_ password: String) -> Bool {
//        // ตรวจสอบความยาวอย่างน้อย 8 ตัว
//        guard password.count >= 8 else { return false }
//        
//        // ตรวจสอบว่ามีตัวอักษรพิมพ์ใหญ่อย่างน้อย 1 ตัว
//        let uppercaseLetterRegex = ".*[A-Z].*"
//        let uppercaseLetterPredicate = NSPredicate(format: "SELF MATCHES %@", uppercaseLetterRegex)
//        guard uppercaseLetterPredicate.evaluate(with: password) else { return false }
//        
//        // ตรวจสอบว่ามีตัวอักษรพิมพ์เล็กอย่างน้อย 1 ตัว
//        let lowercaseLetterRegex = ".*[a-z].*"
//        let lowercaseLetterPredicate = NSPredicate(format: "SELF MATCHES %@", lowercaseLetterRegex)
//        guard lowercaseLetterPredicate.evaluate(with: password) else { return false }
//        
//        // ตรวจสอบว่ามีตัวเลขอย่างน้อย 1 ตัว
//        let digitRegex = ".*[0-9].*"
//        let digitPredicate = NSPredicate(format: "SELF MATCHES %@", digitRegex)
//        guard digitPredicate.evaluate(with: password) else { return false }
//        
//        return true
//    }
//    
//    private func isValidEmail(_ email: String) -> Bool {
//        // เงื่อนไขเข้มงวดสำหรับการตรวจสอบอีเมล
//        let emailRegex = "^(?=[A-Z0-9a-z._%+-]{1,64}@)(?!.*[-]{2,})[A-Z0-9a-z]([A-Z0-9a-z._%+-]*[A-Z0-9a-z])?@[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?\\.[A-Za-z]{2,64}$"
//        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
//        return emailPredicate.evaluate(with: email)
//    }
//    
//    private func filterPasswordInput(_ input: String) -> String {
//        let allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
//        // ไม่ตัดความยาวรหัสผ่านแล้ว เพื่อให้ตรงกับเงื่อนไขความยาวในการตรวจสอบ
//        return String(input.filter { allowedCharacters.contains($0) })
//    }
//    
//    private func filterEmailInput(_ input: String) -> String {
//        // กำหนดอักขระที่อนุญาตในอีเมลให้ชัดเจน โดยไม่ใช้ isLetter ที่อาจมีปัญหา
//        let allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@.-_+%"
//        return String(input.filter { allowedCharacters.contains($0) })
//    }
//    
//    private func borderColor(for value: String, isPassword: Bool = false, isEmail: Bool = false) -> Color {
//        // ถ้าไม่มีข้อมูล ให้แสดงเป็นสีปกติ (สีดำ)
//        if value.isEmpty {
//            return .jetblack
//        }
//        
//        // ตรวจสอบความถูกต้องตามประเภทข้อมูล
//        if isPassword {
//            return isValidPassword(value) ? .green : .red
//        } else if isEmail {
//            return isValidEmail(value) ? .green : .red
//        }
//        
//        // สำหรับ TextField ทั่วไป ให้เป็นสีเขียวเมื่อมีข้อมูล
//        return .green
//    }
//}
//
//#Preview {
//    CustomTextFieldView(sfIcon: "envelope", iconTint: .gray, hint: "อีเมล", isEmail: true, value: .constant(""))
//}

import SwiftUI

struct CustomTextFieldView: View {
    var sfIcon: String
    var iconTint: Color
    var hint: String
    var isPassword: Bool = false
    var isEmail: Bool = false
    @Binding var value: String
    @State private var showPassword: Bool = false
    
    var body: some View {
        HStack (alignment: .top, spacing: 8) {
            VStack (alignment: .leading, spacing: 8) {
                if isPassword {
                    Group {
                        if showPassword {
                            textField(secure: false)
                        } else {
                            textField(secure: true)
                        }
                    }
                } else if isEmail {
                    textField(secure: false, email: true)
                } else {
                    textField(secure: false)
                }
            }
            .font(customFont(type: .regular, textStyle: .callout))
            .overlay(alignment: .leadingFirstTextBaseline) {
                Image(systemName: sfIcon)
                    .foregroundStyle(iconTint)
                    .frame(width: 24)
                    .padding(.horizontal, 8)
            }
            .overlay(alignment: .trailing) {
                if isPassword {
                    Button(action: {
                        withAnimation {
                            showPassword.toggle()
                        }
                    }, label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundStyle(.jetblack)
                            .padding(10)
                            .contentShape(.rect)
                    })
                }
            }
        }
    }
    
    
    private func textField(secure: Bool, email: Bool = false) -> some View {
        let textField = secure ?
            AnyView(SecureField(hint, text: $value)) :
            AnyView(TextField(hint, text: $value))
        
        return textField
            .textInputAutocapitalization(.never)
            .keyboardType(email ? .emailAddress : .default)
            .onChange(of: value) { _, newValue in
                value = filterInput(newValue, isEmail: email, isPassword: secure)
            }
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
    }
    
    private func filterInput(_ input: String, isEmail: Bool = false, isPassword: Bool = false) -> String {
        var allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        
        if isEmail {
            allowedCharacters += "@.-_+%"
        }
        
        return String(input.filter { allowedCharacters.contains($0) })
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        guard password.count >= 8 else { return false }
        
        let hasUppercase = password.contains { $0.isUppercase }
        let hasLowercase = password.contains { $0.isLowercase }
        let hasDigit = password.contains { $0.isNumber }
        
        return hasUppercase && hasLowercase && hasDigit
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^(?=[A-Z0-9a-z._%+-]{1,64}@)(?!.*[-]{2,})[A-Z0-9a-z]([A-Z0-9a-z._%+-]*[A-Z0-9a-z])?@[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email) && email.count <= 254
    }
    
    private func borderColor(for value: String) -> Color {
        if value.isEmpty {
            return .jetblack
        }
        
        if isPassword {
            return isValidPassword(value) ? .greenMint : .coralRed
        } else if isEmail {
            return isValidEmail(value) ? .greenMint : .coralRed
        }
        
        return .greenMint
    }
}

#Preview {
    CustomTextFieldView(sfIcon: "envelope", iconTint: .gray, hint: "อีเมล", isEmail: true, value: .constant(""))
}
