//
//  CustomTextFieldView.swift
//  Kidzzle
//
//  Created by aynnipa on 1/3/2568 BE.
//

import SwiftUI
import SwiftEmailValidator

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
        } else if isPassword {
            allowedCharacters += "!@#$%^&*()_-+={}[]|:;<>,.?/~`"
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
    
    func isValidEmail(_ email: String) -> Bool {
        let allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.@_-+"
        let hasInvalidChars = email.contains { !allowedCharacters.contains($0) }
        
        if hasInvalidChars {
            return false
        }
        
        return SwiftEmailValidator.EmailSyntaxValidator.correctlyFormatted(email)
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
