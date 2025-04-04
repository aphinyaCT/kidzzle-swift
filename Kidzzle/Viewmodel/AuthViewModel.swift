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
    
    init() {
        loadSavedUserData()
    }
    
    func saveAuthData(token: String) {
        UserDefaults.standard.set(token, forKey: "auth_token")
        
        DispatchQueue.main.async {
            self.token = token
            self.isAuthenticated = true
            self.errorMessage = nil
        }
    }

    private func loadSavedUserData() {
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            self.token = token
            self.isAuthenticated = true
        }
    }
    
    @MainActor
    func register(email: String, password: String) async -> (success: Bool, message: String) {
        if password.count < 8 {
            self.errorMessage = "รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร"
            return (false, "รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร")
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
                // ลงทะเบียนสำเร็จ
                return (true, response.message ?? "ลงทะเบียนสำเร็จ")
            } else {
                self.errorMessage = response.message
                return (false, response.message ?? "การลงทะเบียนล้มเหลว")
            }
        } catch let error as AuthError {
            self.isLoading = false
            
            switch error {
            case .serverError(let message):
                self.errorMessage = message
                return (false, message)
            default:
                self.errorMessage = error.localizedDescription
                return (false, error.localizedDescription)
            }
        } catch {
            self.isLoading = false
            handleError(error)
            return (false, self.errorMessage ?? "เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ")
        }
    }
    
    // ล็อกอิน
    @MainActor
    func login(email: String, password: String) async -> (success: Bool, message: String) {
        if password.count < 8 {
            self.errorMessage = "รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร"
            return (false, "รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร")
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
                    return (false, "ไม่ได้รับ access token จากเซิร์ฟเวอร์")
                }
                
                // บันทึกข้อมูล
                saveAuthData(token: accessToken)
                
                return (true, response.message ?? "เข้าสู่ระบบสำเร็จ")
            } else {
                self.errorMessage = response.message
                return (false, response.message ?? "การเข้าสู่ระบบล้มเหลว")
            }
        } catch let error as AuthError {
            self.isLoading = false
            
            switch error {
            case .serverError(let message):
                self.errorMessage = message
                return (false, message)
            default:
                self.errorMessage = error.localizedDescription
                return (false, error.localizedDescription)
            }
        } catch {
            self.isLoading = false
            handleError(error)
            return (false, self.errorMessage ?? "เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ")
        }
    }

    // สำหรับ Social Login
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
                    return (false, "ไม่ได้รับ access token จากเซิร์ฟเวอร์")
                }
                
                // บันทึกข้อมูล
                saveAuthData(token: accessToken)
                
                return (true, response.message)
            } else {
                self.errorMessage = response.message
                return (false, response.message)
            }
        } catch let error as AuthError {
            self.isLoading = false
            
            switch error {
            case .serverError(let message):
                self.errorMessage = message
                return (false, message)
            default:
                self.errorMessage = error.localizedDescription
                return (false, error.localizedDescription)
            }
        } catch {
            self.isLoading = false
            handleError(error)
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
                        continuation.resume(returning: (false, "Google login error: \(error.localizedDescription)"))
                        return
                    }
                    
                    guard let user = result?.user else {
                        self?.handleLoginError(error: NSError(domain: "LoginError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user found"]), method: "Google")
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
    
    // จัดการการล็อกอินด้วย Google
    private func handleGoogleLogin(user: GIDGoogleUser) async -> (success: Bool, message: String) {
        let accessToken = user.accessToken.tokenString
        print("✅ Google Access Token: \(accessToken)")
        
        guard let idToken = user.idToken?.tokenString else {
            handleLoginError(error: NSError(domain: "LoginError", code: -1, userInfo: [NSLocalizedDescriptionKey: "ID Token is missing"]), method: "Google")
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
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let response = try await authService.requestResetPassword(email: email)
            
            self.isLoading = false
            
            if response.code == 200 {
                self.resetToken = response.token
                print("รีเซ็ตรหัสผ่านสำเร็จ สามารถตั้งรหัสผ่านใหม่ได้ทันที")
                return (true, "ส่งคำขอรีเซ็ตรหัสผ่านสำเร็จ กรุณาตรวจสอบอีเมล")
            } else {
                let errorMessage = "ไม่สามารถส่งคำขอรีเซ็ตรหัสผ่านได้ กรุณาลองใหม่อีกครั้ง"
                self.errorMessage = errorMessage
                return (false, errorMessage)
            }
        } catch let error as AuthError {
            self.isLoading = false
            
            switch error {
            case .serverError:
                let errorMessage = "เกิดข้อผิดพลาดที่เซิร์ฟเวอร์ กรุณาลองใหม่อีกครั้ง"
                self.errorMessage = errorMessage
                return (false, errorMessage)
            case .networkError:
                let errorMessage = "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต"
                self.errorMessage = errorMessage
                return (false, errorMessage)
            case .invalidURL, .invalidResponse, .decodingError:
                let errorMessage = "เกิดข้อผิดพลาดในการประมวลผล กรุณาลองใหม่อีกครั้ง"
                self.errorMessage = errorMessage
                return (false, errorMessage)
            }
        } catch {
            self.isLoading = false
            
            let errorMessage = "เกิดข้อผิดพลาดที่ไม่คาดคิด กรุณาลองใหม่อีกครั้ง"
            self.errorMessage = errorMessage
            return (false, errorMessage)
        }
    }

    // ในฟังก์ชัน resetPassword
    @MainActor
    func resetPassword(newPassword: String) async -> (success: Bool, message: String) {
        guard let token = self.resetToken else {
            self.errorMessage = "ไม่พบโทเค็นสำหรับรีเซ็ตรหัสผ่าน กรุณาส่งคำขอรีเซ็ตใหม่"
            return (false, "ไม่พบโทเค็นสำหรับรีเซ็ตรหัสผ่าน กรุณาส่งคำขอรีเซ็ตใหม่")
        }
        
        if newPassword.count < 8 {
            self.errorMessage = "รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร"
            return (false, "รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร")
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let response = try await authService.resetPassword(newPassword: newPassword, token: token)
            
            self.isLoading = false
            
            if response.code == 200 {
                print("รีเซ็ตรหัสผ่านสำเร็จ: \(response.message)")
                self.resetToken = nil
                return (true, "รีเซ็ตรหัสผ่านสำเร็จ")
            } else {
                let errorMessage = "ไม่สามารถรีเซ็ตรหัสผ่านได้ กรุณาลองใหม่อีกครั้ง"
                self.errorMessage = errorMessage
                return (false, errorMessage)
            }
        } catch let error as AuthError {
            self.isLoading = false
            
            switch error {
            case .serverError(let message):
                self.errorMessage = message
                return (false, message)
            default:
                let errorMessage = "เกิดข้อผิดพลาดในการรีเซ็ตรหัสผ่าน"
                self.errorMessage = errorMessage
                return (false, errorMessage)
            }
        } catch {
            self.isLoading = false
            let errorMessage = "เกิดข้อผิดพลาดที่ไม่คาดคิด"
            self.errorMessage = errorMessage
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
