//
//  AuthViewModel.swift
//  Kidzzle
//
//  Created by aynnipa on 4/3/2568 BE.
//

import Foundation
import SwiftUI
import GoogleSignIn

class AuthViewModel: ObservableObject {
    private let authService = AuthAPIService()
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    @Published var user: User?
    @Published var token: String?
    @Published var userId: String?
    @Published var resetToken: String?
    
    // MARK: Login Toast
    @Published var showLoginSuccessToast = false
    @Published var showLoginErrorToast = false
    
    // MARK: Register Toast
    @Published var showRegisterSuccessToast = false
    @Published var showRegisterErrorToast = false
    
    // MARK: Social Login Toast
    @Published var showSocialLoginSuccessToast = false
    @Published var showSocialLoginErrorToast = false
    
    // MARK: Request Reset Password Toast
    @Published var showRequestResetPasswordSuccessToast = false
    @Published var showRequestResetPasswordErrorToast = false
    
    // MARK: Reset Password Toast
    @Published var showResetPasswordSuccessToast = false
    @Published var showResetPasswordErrorToast = false
    
    // MARK: Invalid Email & Password Toast
    @Published var showInvalidCredentialsToast = false
    
    // MARK: Logout Toast
    @Published var showLogoutSuccessToast = false
    
    init() {
        // โหลดข้อมูลที่บันทึกไว้เมื่อเริ่มต้น
        loadSavedUserData()
    }
    
    // เก็บข้อมูลการล็อกอิน
    func saveAuthData(token: String) {
        UserDefaults.standard.set(token, forKey: "auth_token")
        
        DispatchQueue.main.async {
            self.token = token
            self.isAuthenticated = true
            self.errorMessage = nil
        }
    }

    // โหลดข้อมูลผู้ใช้ที่บันทึกไว้
    private func loadSavedUserData() {
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            self.token = token
            self.isAuthenticated = true
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^(?=[A-Z0-9a-z._%+-]{1,64}@)(?!.*[-]{2,})[A-Z0-9a-z]([A-Z0-9a-z._%+-]*[A-Z0-9a-z])?@[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func isStrongPassword(_ password: String) -> Bool {
        // ตรวจสอบความยาวขั้นต่ำ
        guard password.count >= 8 else { return false }
        
        // ตรวจสอบว่ามีตัวพิมพ์ใหญ่อย่างน้อย 1 ตัว
        let uppercaseLetterRegex = ".*[A-Z]+.*"
        if !NSPredicate(format: "SELF MATCHES %@", uppercaseLetterRegex).evaluate(with: password) {
            return false
        }
        
        // ตรวจสอบว่ามีตัวพิมพ์เล็กอย่างน้อย 1 ตัว
        let lowercaseLetterRegex = ".*[a-z]+.*"
        if !NSPredicate(format: "SELF MATCHES %@", lowercaseLetterRegex).evaluate(with: password) {
            return false
        }
        
        // ตรวจสอบว่ามีตัวเลขอย่างน้อย 1 ตัว
        let digitRegex = ".*[0-9]+.*"
        if !NSPredicate(format: "SELF MATCHES %@", digitRegex).evaluate(with: password) {
            return false
        }
        
        return true
    }
    
    @MainActor
    func register(email: String, password: String) async -> (success: Bool, message: String) {
        if !isValidEmail(email) || !isStrongPassword(password) {
            self.errorMessage = "รูปแบบอีเมลหรือรหัสผ่านไม่ถูกต้อง"
            self.showInvalidCredentialsToast = true
            return (false, "ข้อมูลไม่ถูกต้อง")
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let response = try await authService.registerRequest(
                email: email,
                password: password
            )
            
            self.isLoading = false
            
            if response.code == 200 {
                self.showRegisterSuccessToast = true
                return (true, response.message ?? "ลงทะเบียนสำเร็จ")
            } else {
                self.errorMessage = response.message
                self.showRegisterErrorToast = true
                return (false, response.message ?? "การลงทะเบียนล้มเหลว")
            }
        } catch let error as AuthError {
            self.isLoading = false
            
            switch error {
            case .serverError(let message):
                self.errorMessage = message
                self.showRegisterErrorToast = true
                return (false, message)
            default:
                self.errorMessage = error.localizedDescription
                self.showRegisterErrorToast = true
                return (false, error.localizedDescription)
            }
        } catch {
            self.isLoading = false
            handleError(error)
            self.showRegisterErrorToast = true
            return (false, self.errorMessage ?? "เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ")
        }
    }
    
    
    @MainActor
    func login(email: String, password: String) async -> (success: Bool, message: String) {
        if !isValidEmail(email) || !isStrongPassword(password) {
            self.errorMessage = "รูปแบบอีเมลหรือรหัสผ่านไม่ถูกต้อง"
            self.showInvalidCredentialsToast = true
            return (false, "ข้อมูลไม่ถูกต้อง")
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let response = try await authService.loginRequest(
                email: email,
                password: password
            )
            
            self.isLoading = false
            
            if response.code == 200 {
                guard let accessToken = response.access_token else {
                    self.errorMessage = "ไม่ได้รับ access token จากเซิร์ฟเวอร์"
                    self.showLoginErrorToast = true // เพิ่มบรรทัดนี้
                    return (false, "ไม่ได้รับ access token จากเซิร์ฟเวอร์")
                }
                
                // บันทึกข้อมูล
                saveAuthData(token: accessToken)
                
                self.showLoginSuccessToast = true // เพิ่มบรรทัดนี้
                return (true, response.message ?? "เข้าสู่ระบบสำเร็จ")
            } else {
                self.errorMessage = response.message
                self.showLoginErrorToast = true // เพิ่มบรรทัดนี้
                return (false, response.message ?? "การเข้าสู่ระบบล้มเหลว")
            }
        } catch let error as AuthError {
            self.isLoading = false
            
            switch error {
            case .serverError(let message):
                self.errorMessage = message
                self.showLoginErrorToast = true // เพิ่มบรรทัดนี้
                return (false, message)
            default:
                self.errorMessage = error.localizedDescription
                self.showLoginErrorToast = true // เพิ่มบรรทัดนี้
                return (false, error.localizedDescription)
            }
        } catch {
            self.isLoading = false
            handleError(error)
            self.showLoginErrorToast = true // เพิ่มบรรทัดนี้
            return (false, self.errorMessage ?? "เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ")
        }
    }

    @MainActor
    func socialLogin(email: String, method: String, token: String) async -> (success: Bool, message: String) {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let response = try await authService.socialLoginRequest(email: email, method: method, token: token)
            
            self.isLoading = false
            
            if response.code == 200 {
                guard let accessToken = response.access_token else {
                    self.errorMessage = "ไม่ได้รับ access token จากเซิร์ฟเวอร์"
                    self.showSocialLoginErrorToast = true  // เพิ่มบรรทัดนี้
                    return (false, "ไม่ได้รับ access token จากเซิร์ฟเวอร์")
                }
                
                // บันทึกข้อมูล
                saveAuthData(token: accessToken)
                self.showSocialLoginSuccessToast = true
                return (true, response.message)
            } else {
                self.errorMessage = response.message
                self.showSocialLoginErrorToast = true
                return (false, response.message)
            }
        } catch let error as AuthError {
            self.isLoading = false
            
            switch error {
            case .serverError(let message):
                self.errorMessage = message
                self.showSocialLoginErrorToast = true
                return (false, message)
            default:
                self.errorMessage = error.localizedDescription
                self.showSocialLoginErrorToast = true
                return (false, error.localizedDescription)
            }
        } catch {
            self.isLoading = false
            handleError(error)
            self.showSocialLoginErrorToast = true
            return (false, self.errorMessage ?? "เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ")
        }
    }
    
    @MainActor
    func loginWithGoogle() async -> (success: Bool, message: String) {
        return await withCheckedContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(withPresenting: UIApplication.shared.getRootViewController()) { [weak self] result, error in
                Task { @MainActor in
                    if let error = error {
                        self?.handleLoginError(error: error, method: "Google")
                        self?.showSocialLoginErrorToast = true // เพิ่มบรรทัดนี้
                        continuation.resume(returning: (false, "Google login error: \(error.localizedDescription)"))
                        return
                    }
                    
                    guard let user = result?.user else {
                        self?.handleLoginError(error: NSError(domain: "LoginError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user found"]), method: "Google")
                        self?.showSocialLoginErrorToast = true // เพิ่มบรรทัดนี้
                        continuation.resume(returning: (false, "ไม่พบข้อมูลผู้ใช้จาก Google"))
                        return
                    }
                    
                    do {
                        let result = await self?.handleGoogleLogin(user: user) ?? (false, "เกิดข้อผิดพลาดในการเข้าสู่ระบบด้วย Google")
                        continuation.resume(returning: result)
                    }
                }
            }
        }
    }

    private func handleGoogleLogin(user: GIDGoogleUser) async -> (success: Bool, message: String) {
        let accessToken = user.accessToken.tokenString
        print("✅ Google Access Token: \(accessToken)")
        
        guard let idToken = user.idToken?.tokenString else {
            handleLoginError(error: NSError(domain: "LoginError", code: -1, userInfo: [NSLocalizedDescriptionKey: "ID Token is missing"]), method: "Google")
            self.showSocialLoginErrorToast = true // เพิ่มบรรทัดนี้
            return (false, "ไม่พบ ID Token จาก Google")
        }
        
        let email = user.profile?.email ?? "Email not available"
        
        print("✅ Google ID Token: \(idToken)")
        print("✅ Google Email: \(email)")

        // ส่งข้อมูลไปยัง API
        return await socialLogin(email: email, method: "google", token: idToken)
    }
    
    func handleLoginError(error: Error, method: String) {
        DispatchQueue.main.async {
            self.errorMessage = "\(method) login error: \(error.localizedDescription)"
            print("❌ \(self.errorMessage ?? "")")
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        
        token = nil
        user = nil
        isAuthenticated = false
        errorMessage = nil
        resetToken = nil
        
        UserDefaults.standard.removeObject(forKey: "auth_token")
        
        self.showLogoutSuccessToast = true
    }
    
    private func handleError(_ error: Error) {
        if let authError = error as? AuthError {
            switch authError {
            case .serverError(let message):
                self.errorMessage = message
            case .networkError(let underlyingError):
                self.errorMessage = "โปรดตรวจสอบการเชื่อมต่ออินเทอร์เน็ต: \(underlyingError.localizedDescription)"
            case .invalidURL:
                self.errorMessage = "URL ไม่ถูกต้อง"
            case .invalidResponse:
                self.errorMessage = "การตอบกลับจากเซิร์ฟเวอร์ไม่ถูกต้อง"
            case .decodingError(let decodingError):
                self.errorMessage = "เกิดข้อผิดพลาดในการแปลงข้อมูล: \(decodingError.localizedDescription)"
            }
        } else {
            self.errorMessage = "เกิดข้อผิดพลาด: \(error.localizedDescription)"
        }
        
        print("Error: \(self.errorMessage ?? "Unknown error")")
    }
    
    // ในฟังก์ชัน requestPasswordReset
    @MainActor
    func requestPasswordReset(email: String) async -> (success: Bool, message: String) {
        if email.isEmpty {
            self.errorMessage = "กรุณากรอกอีเมล"
            return (false, "กรุณากรอกอีเมล")
        }
        
        // ตรวจสอบรูปแบบอีเมล
        if !isValidEmail(email) {
            self.errorMessage = "รูปแบบอีเมลไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง"
            self.showInvalidCredentialsToast = true
            return (false, "รูปแบบอีเมลไม่ถูกต้อง")
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let response = try await authService.requestResetPassword(email: email)
            
            self.isLoading = false
            
            if response.code == 200 {
                self.resetToken = response.token
                print("รีเซ็ตรหัสผ่านสำเร็จ สามารถตั้งรหัสผ่านใหม่ได้ทันที")
                // เพิ่ม toast สำเร็จ
                self.showRequestResetPasswordSuccessToast = true
                return (true, "ส่งคำขอรีเซ็ตรหัสผ่านสำเร็จ กรุณาตรวจสอบอีเมล")
            } else {
                let errorMessage = "ไม่สามารถส่งคำขอรีเซ็ตรหัสผ่านได้ กรุณาลองใหม่อีกครั้ง"
                self.errorMessage = errorMessage
                // เพิ่ม toast ผิดพลาด
                self.showRequestResetPasswordErrorToast = true
                return (false, errorMessage)
            }
        } catch let error as AuthError {
            self.isLoading = false
            
            switch error {
            case .serverError:
                let errorMessage = "เกิดข้อผิดพลาดที่เซิร์ฟเวอร์ กรุณาลองใหม่อีกครั้ง"
                self.errorMessage = errorMessage
                self.showRequestResetPasswordErrorToast = true
                return (false, errorMessage)
            case .networkError:
                let errorMessage = "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต"
                self.errorMessage = errorMessage
                self.showRequestResetPasswordErrorToast = true
                return (false, errorMessage)
            case .invalidURL, .invalidResponse, .decodingError:
                let errorMessage = "เกิดข้อผิดพลาดในการประมวลผล กรุณาลองใหม่อีกครั้ง"
                self.errorMessage = errorMessage
                self.showRequestResetPasswordErrorToast = true
                return (false, errorMessage)
            }
        } catch {
            self.isLoading = false
            
            let errorMessage = "เกิดข้อผิดพลาดที่ไม่คาดคิด กรุณาลองใหม่อีกครั้ง"
            self.errorMessage = errorMessage
            self.showRequestResetPasswordErrorToast = true
            return (false, errorMessage)
        }
    }

    // ในฟังก์ชัน resetPassword
    @MainActor
    func resetPassword(newPassword: String) async -> (success: Bool, message: String) {
        guard let token = self.resetToken else {
            self.errorMessage = "ไม่พบโทเค็นสำหรับรีเซ็ตรหัสผ่าน กรุณาส่งคำขอรีเซ็ตใหม่"
            self.showResetPasswordErrorToast = true
            return (false, "ไม่พบโทเค็นสำหรับรีเซ็ตรหัสผ่าน กรุณาส่งคำขอรีเซ็ตใหม่")
        }
        
        // ตรวจสอบความแข็งแรงของรหัสผ่าน
        if !isStrongPassword(newPassword) {
            self.errorMessage = "รหัสผ่านต้องมี 8 ตัวอักษรเท่านั้น ประกอบด้วยตัวพิมพ์ใหญ่ ตัวพิมพ์เล็ก และตัวเลข"
            self.showInvalidCredentialsToast = true
            return (false, "รหัสผ่านไม่ตรงตามเงื่อนไข")
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let response = try await authService.resetPassword(newPassword: newPassword, token: token)
            
            self.isLoading = false
            
            if response.code == 200 {
                print("รีเซ็ตรหัสผ่านสำเร็จ: \(response.message)")
                self.resetToken = nil
                // เพิ่ม toast สำเร็จ
                self.showResetPasswordSuccessToast = true
                return (true, "รีเซ็ตรหัสผ่านสำเร็จ")
            } else {
                let errorMessage = "ไม่สามารถรีเซ็ตรหัสผ่านได้ กรุณาลองใหม่อีกครั้ง"
                self.errorMessage = errorMessage
                // เพิ่ม toast ผิดพลาด
                self.showResetPasswordErrorToast = true
                return (false, errorMessage)
            }
        } catch let error as AuthError {
            self.isLoading = false
            
            switch error {
            case .serverError(let message):
                self.errorMessage = message
                self.showResetPasswordErrorToast = true
                return (false, message)
            default:
                let errorMessage = "เกิดข้อผิดพลาดในการรีเซ็ตรหัสผ่าน"
                self.errorMessage = errorMessage
                self.showResetPasswordErrorToast = true
                return (false, errorMessage)
            }
        } catch {
            self.isLoading = false
            let errorMessage = "เกิดข้อผิดพลาดที่ไม่คาดคิด"
            self.errorMessage = errorMessage
            self.showResetPasswordErrorToast = true
            return (false, errorMessage)
        }
    }
}

extension UIApplication {
    func getRootViewController() -> UIViewController {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        
        guard let root = scene.windows.first?.rootViewController else {
            return .init()
        }
        
        return root
    }
}
