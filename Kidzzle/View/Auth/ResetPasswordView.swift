//
//  ResetPasswordView.swift
//  Kidzzle
//
//  Created by aynnipa on 28/3/2568 BE.
//

import SwiftUI
import SwiftEmailValidator

struct ResetPasswordView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var step: Int = 1
    @State private var isEmailValid: Bool = false
    @State private var isPasswordValid: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            VStack (spacing: 0) {
                
                Button(action: {
                    dismiss()
                }, label:{
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .padding()
                        .frame(width: 40, height: 40)
                        .background(Color.jetblack)
                        .cornerRadius(10)
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                VStack (alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: step == 1 ? "person.badge.key.fill" : "key.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.jetblack)
                        
                        Text(step == 1 ? "ส่งคำขอเปลี่ยนรหัสผ่าน" : "ตั้งรหัสผ่านใหม่")
                            .font(customFont(type: .bold, textStyle: .title2))
                            .foregroundColor(.jetblack)
                        
                        Text(step == 1 ? "กรอกอีเมลของคุณ" : "กรอกรหัสผ่านใหม่")
                            .font(customFont(type: .regular, textStyle: .callout))
                            .foregroundColor(.jetblack)
                    }
                    .padding(.top, 24)
                    
                    if step == 1 {
                        CustomTextFieldView(
                            sfIcon: "at",
                            iconTint: .jetblack,
                            hint: "อีเมล",
                            isEmail: true,
                            value: $email
                        )
                        .onChange(of: email) { _, newValue in
                            if !newValue.isEmpty {
                                let hasAtSymbol = newValue.contains("@")
                                let hasDotAfterAt = hasAtSymbol && newValue.split(separator: "@").count > 1 && newValue.split(separator: "@")[1].contains(".")
                                isEmailValid = hasAtSymbol && hasDotAfterAt && newValue.count >= 5
                            } else {
                                isEmailValid = false
                            }
                        }
                        
                        Button(action: {
                            Task {
                                let result = await authViewModel.requestPasswordReset(email: email)
                                if result.success {
                                    step = 2
                                }
                            }
                        }, label: {
                            ZStack {
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .frame(width: 24, height: 24)
                                } else {
                                    Text("ตรวจสอบอีเมล")
                                        .font(customFont(type: .semibold, textStyle: .body))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .frame(height: 44)
                            .background(isEmailValid ? .jetblack : .gray.opacity(0.5))
                            .cornerRadius(10)
                        })
                        .contentShape(.rect)
                        .disabled(!isEmailValid || authViewModel.isLoading)
                        .onChange(of: email) { _, newValue in
                            isEmailValid = SwiftEmailValidator.EmailSyntaxValidator.correctlyFormatted(newValue)
                        }
                        
                    } else {
                        CustomTextFieldView(
                            sfIcon: "lock",
                            iconTint: .jetblack,
                            hint: "รหัสผ่านใหม่",
                            isPassword: true,
                            value: $password
                        )
                        .onChange(of: password) { _, newValue in
                            // ตรวจสอบเงื่อนไขพื้นฐานของรหัสผ่าน
                            let hasUppercase = newValue.contains { $0.isUppercase }
                            let hasLowercase = newValue.contains { $0.isLowercase }
                            let hasDigit = newValue.contains { $0.isNumber }
                            isPasswordValid = newValue.count >= 8 && hasUppercase && hasLowercase && hasDigit
                        }
                        
                        // MARK: Real-time Check Create Password
                        PasswordValidator(password: $password)
                        
                        Button(action: {
                            Task {
                                let result = await authViewModel.resetPassword(newPassword: password)
                                if result.success {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        dismiss()
                                    }
                                }
                            }
                        }, label: {
                            ZStack {
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .frame(width: 24, height: 24)
                                } else {
                                    Text("เปลี่ยนรหัสผ่าน")
                                        .font(customFont(type: .semibold, textStyle: .body))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(isPasswordValid ? .jetblack : .gray.opacity(0.5))
                            .cornerRadius(10)
                        })
                        .contentShape(.rect)
                        .disabled(!isPasswordValid || authViewModel.isLoading)
                    }
                    
                    Spacer()
                    
                }
            }
            .padding(.top, 40)
            .padding(.horizontal, 16)
            .background(.ivorywhite)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.keyboard)
            .toast(isShowing: $authViewModel.showRequestResetPasswordSuccessToast, toastCase: .requestResetPasswordSuccess)
            .toast(isShowing: $authViewModel.showRequestResetPasswordErrorToast, toastCase: .requestResetPasswordError)
            .toast(isShowing: $authViewModel.showResetPasswordSuccessToast, toastCase: .resetPasswordSuccess)
            .toast(isShowing: $authViewModel.showResetPasswordErrorToast, toastCase: .resetPasswordError)
            .toast(isShowing: $authViewModel.showInvalidCredentialsToast, toastCase: .invalidCredentials)
        }
    }
}

#Preview {
    ResetPasswordView()
        .environmentObject(AuthViewModel())
}
