//
//  SignUpView.swift
//  Kidzzle
//
//  Created by aynnipa on 3/3/2568 BE.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showPrivacyPolicySheet = false
    
    var body: some View {
        VStack (spacing: 0) {
            
            Button(action: {
                dismiss()
            }, label:{
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundStyle(.jetblack)
                    .padding()
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .cornerRadius(10)
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            VStack (alignment: .leading, spacing: 24) {
                
                VStack (alignment: .leading, spacing: 10) {
                    Text("สมัครสมาชิก Kidzzle!")
                        .font(customFont(type: .bold, textStyle: .title2))
                        .foregroundColor(.jetblack)
                        .padding(.top, 24)
                    
                    Text("กรอกอีเมลและรหัสผ่านของคุณ")
                        .font(customFont(type: .regular, textStyle: .callout))
                        .foregroundColor(.jetblack)
                }
                
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
                
                // MARK: Real-time Check Create Password
                PasswordValidator(password: $password)
                
                // MARK: Sign UP Buttton
                Button(action: {
                    Task {
                        await authViewModel.register(email: email, password: password)
                    }
                }, label: {
                    ZStack {
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(width: 24, height: 24)
                        } else {
                            Text("สมัครสมาชิก")
                                .font(customFont(type: .semibold, textStyle: .body))
                        }
                    }
                })
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(.jetblack)
                .cornerRadius(10)
                .disabled(password.isEmpty || email.isEmpty)
                
                Button {
                    showPrivacyPolicySheet = true
                } label: {
                    Text("นโยบายความเป็นส่วนตัวของ Kidzzle")
                        .font(customFont(type: .regular, textStyle: .caption1))
                        .foregroundColor(.jetblack)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .fullScreenCover(isPresented: $showPrivacyPolicySheet) {
                    PrivacyPolicyView(agreed: $showPrivacyPolicySheet)
                        .environmentObject(authViewModel)
                        .presentationDetents([.large])
                        .interactiveDismissDisabled()
                }
                
                Spacer()
                
            }
        }
        .padding(.top, 40)
        .padding(.horizontal, 16)
        .background(.ivorywhite)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.keyboard)
        .toast(isShowing: $authViewModel.showRegisterSuccessToast, toastCase: .registerSuccess, duration: 1.5)
        .toast(isShowing: $authViewModel.showRegisterErrorToast, toastCase: .registerError, duration: 1.5)
        .toast(isShowing: $authViewModel.showInvalidCredentialsToast, toastCase: .invalidCredentials, duration: 1.5)
        .onChange(of: authViewModel.showRegisterSuccessToast) { oldValue, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}
