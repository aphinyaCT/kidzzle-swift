//
//  AuthView.swift
//  Kidzzle
//
//  Created by aynnipa on 1/3/2568 BE.
//

import SwiftUI
import GoogleSignIn
import SwiftEmailValidator

struct AuthView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Properties
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var token: String = ""
    
    @Binding var isLoggedIn: Bool
    @Binding var showChildDevelopment: Bool
    @Binding var showForgotPassword: Bool
    @Binding var isSubmitting: Bool
    
    @State private var showRegistrationSheet = false
    @State private var showLoginSheet = false
    @State private var showResetPasswordSheet = false
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.ivorywhite
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 24) {
                            Image("KIDZZLE-MASCOT")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 150, height: 150)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 40)
                            
                            Text("ยินดีต้อนรับเข้าสู่ Kidzzle!")
                                .font(customFont(type: .bold, textStyle: .title2))
                                .foregroundColor(.jetblack)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 10)
                            
                            CustomTextFieldView(
                                sfIcon: "at",
                                iconTint: .jetblack,
                                hint: "อีเมล",
                                isEmail: true,
                                value: $email
                            )
                            
                            CustomTextFieldView(
                                sfIcon: "lock",
                                iconTint: .jetblack,
                                hint: "รหัสผ่าน",
                                isPassword: true,
                                value: $password
                            )
                            
                            Button(action: {
                                showResetPasswordSheet.toggle()
                            }) {
                                Text("ลืมรหัสผ่าน?")
                                    .font(customFont(type: .regular, textStyle: .callout))
                                    .foregroundColor(.jetblack)
                                    .padding(.vertical, 8)
                            }
                            .contentShape(Rectangle())
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            
                            Button {
                                hideKeyboard()
                                isSubmitting = true
                                Task {
                                    let _ = await authViewModel.login(email: email, password: password)
                                    DispatchQueue.main.async {
                                        isSubmitting = false
                                    }
                                }
                            } label: {
                                ZStack {
                                    if isSubmitting || authViewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text("เข้าสู่ระบบ")
                                            .font(customFont(type: .semibold, textStyle: .body))
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(isFormValid ? .jetblack : Color.gray.opacity(0.5))
                                .cornerRadius(10)
                            }
                            .contentShape(.rect)
                            .disabled(email.isEmpty || password.isEmpty || !isFormValid)
                            
                            HStack {
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.gray.opacity(0.3))
                                
                                Text("หรือ")
                                    .font(customFont(type: .regular, textStyle: .callout))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 8)
                                
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.gray.opacity(0.3))
                            }
                            
                            // MARK: Google Button
                            Button {
                                hideKeyboard()
                                Task {
                                    let result = await authViewModel.loginWithGoogle()
                                    if result.success {
                                        dismiss()
                                    }
                                }
                            } label: {
                                HStack {
                                    Image("google-logo", bundle: .main)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 24)
                                    
                                    Text("เข้าใช้งานผ่าน Google")
                                        .font(customFont(type: .semibold, textStyle: .body))
                                        .foregroundColor(.jetblack)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.jetblack, lineWidth: 1)
                                )
                                .cornerRadius(10)
                            }
                            .contentShape(.rect)
                            
                            Spacer()
                            
                            Button {
                                showRegistrationSheet = true
                            } label: {
                                HStack {
                                    Text("คุณยังไม่มีบัญชีใช่หรือไม่?")
                                        .font(customFont(type: .regular, textStyle: .subheadline))
                                        .foregroundColor(.jetblack)
                                    
                                    Text("สมัครสมาชิก")
                                        .font(customFont(type: .bold, textStyle: .subheadline))
                                        .foregroundColor(.jetblack)
                                }
                            }
                            
                        }
                        .padding(.horizontal, 20)
                    }
                    .ignoresSafeArea(.keyboard)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .toast(isShowing: $authViewModel.showLoginErrorToast, toastCase: .loginError, duration: 1.5)
            .toast(isShowing: $authViewModel.showInvalidCredentialsToast , toastCase: .invalidCredentials, duration: 1.5)
            .toast(isShowing: $authViewModel.showLogoutSuccessToast, toastCase: .logoutSuccess, duration: 1.5)
            .toast(isShowing: $authViewModel.showTokenExpiredToast, toastCase: .tokenExpired, duration: 1.5)
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
            .fullScreenCover(isPresented: $showRegistrationSheet) {
                SignUpView()
                    .environmentObject(authViewModel)
                    .interactiveDismissDisabled()
            }
            .fullScreenCover(isPresented: $showResetPasswordSheet) {
                ResetPasswordView()
                    .environmentObject(authViewModel)
                    .interactiveDismissDisabled()
            }
            .onChange(of: authViewModel.isAuthenticated) { oldValue, newValue in
                if newValue {
                    UserDefaults.standard.set(true, forKey: "just_logged_in")
                    isLoggedIn = true
                    isSubmitting = false
                } else if oldValue && !newValue {
                    // ถ้าเคย authenticated แล้วกลายเป็น false (token หมดอายุ)
                    isLoggedIn = false
                    isSubmitting = false
                }
            }
            .onChange(of: authViewModel.errorMessage) { oldValue, newValue in
                if newValue != nil {
                    isSubmitting = false
                }
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private var isFormValid: Bool {
        let isEmailValid = SwiftEmailValidator.EmailSyntaxValidator.correctlyFormatted(email)
        
        let hasUppercase = password.contains { $0.isUppercase }
        let hasLowercase = password.contains { $0.isLowercase }
        let hasDigit = password.contains { $0.isNumber }
        let isPasswordValid = password.count >= 8 && hasUppercase && hasLowercase && hasDigit
        
        return isEmailValid && isPasswordValid
    }
}

// MARK: - Preview
#Preview {
    AuthView(
        isLoggedIn: .constant(false),
        showChildDevelopment: .constant(false),
        showForgotPassword: .constant(false),
        isSubmitting: .constant(false)
    )
    .environmentObject(AuthViewModel())
}
