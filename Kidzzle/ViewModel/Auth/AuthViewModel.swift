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
    // MARK: - Services
    private let authService = AuthAPIService()
    
    // MARK: - Properties
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    @Published var user: User?
    @Published var token: String?
    @Published var userId: String?
    @Published var resetToken: String?
    @Published var accessToken: String = ""
    @Published var tokenExpirationDate: Date?
    @Published var userEmail: String?
    @Published var userPhoto: String?
    
    // MARK: - Token Management
    private var tokenExpirationTimer: Timer?
    private let tokenExpirationInterval: TimeInterval = 3600
    
    // MARK: - Toast Notifications
    // Authentication Toasts
    @Published var showLoginSuccessToast = false
    @Published var showLoginErrorToast = false
    @Published var showRegisterSuccessToast = false
    @Published var showRegisterErrorToast = false
    @Published var showSocialLoginSuccessToast = false
    @Published var showSocialLoginErrorToast = false
    @Published var showLogoutSuccessToast = false
    @Published var showTokenExpiredToast = false
    
    // Password Reset Toasts
    @Published var showRequestResetPasswordSuccessToast = false
    @Published var showRequestResetPasswordErrorToast = false
    @Published var showResetPasswordSuccessToast = false
    @Published var showResetPasswordErrorToast = false
    
    // Validation Toasts
    @Published var showInvalidCredentialsToast = false
    
    // MARK: - Initialization
    init() {
        loadSavedUserData()
    }
    
    deinit {
        invalidateTokenExpirationTimer()
    }
    
    // MARK: - Data Persistence
    func saveAuthData(token: String) {
        let expirationDate = Date().addingTimeInterval(tokenExpirationInterval)
        
        UserDefaults.standard.set(token, forKey: "auth_token")
        UserDefaults.standard.set(expirationDate.timeIntervalSince1970, forKey: "token_expiration_date")
        
        DispatchQueue.main.async {
            self.token = token
            self.accessToken = token
            self.isAuthenticated = true
            self.tokenExpirationDate = expirationDate
            self.errorMessage = nil
            
            self.startTokenExpirationTimer()
        }
    }
    
    private func loadSavedUserData() {
        if let token = UserDefaults.standard.string(forKey: "auth_token"),
           let expirationTimeInterval = UserDefaults.standard.object(forKey: "token_expiration_date") as? TimeInterval {
            
            let expirationDate = Date(timeIntervalSince1970: expirationTimeInterval)
            
            if expirationDate > Date() {
                self.token = token
                self.accessToken = token
                self.isAuthenticated = true
                self.tokenExpirationDate = expirationDate
                
                self.userEmail = UserDefaults.standard.string(forKey: "userEmail")
                self.userId = UserDefaults.standard.string(forKey: "userId")
                self.userPhoto = UserDefaults.standard.string(forKey: "userPhotoURL")
                
                if let email = self.userEmail {
                    self.user = User(
                        id: self.userId ?? "",
                        email: email,
                        photo: self.userPhoto
                    )
                }
                
                startTokenExpirationTimer()
            } else {
                clearTokenData()
            }
        }
    }
    
    @MainActor
    private func saveUserInfo(email: String, userId: String? = nil, photoURL: String? = nil) {
        UserDefaults.standard.set(email, forKey: "userEmail")
        if let userId = userId {
            UserDefaults.standard.set(userId, forKey: "userId")
        }
        if let photoURL = photoURL {
            UserDefaults.standard.set(photoURL, forKey: "userPhotoURL")
        }

        self.userEmail = email
        self.userId = userId
        self.userPhoto = photoURL
        
        self.user = User(
            id: userId ?? "",
            email: email,
            photo: photoURL
        )
    }
    
    // MARK: - Token Management
    private func startTokenExpirationTimer() {
        invalidateTokenExpirationTimer()
        
        guard let expirationDate = tokenExpirationDate else { return }
        
        let remainingTime = expirationDate.timeIntervalSinceNow
        
        if remainingTime <= 0 {
            handleTokenExpiration()
            return
        }
        
        tokenExpirationTimer = Timer.scheduledTimer(withTimeInterval: remainingTime, repeats: false) { [weak self] _ in
            self?.handleTokenExpiration()
        }
    }
    
    private func invalidateTokenExpirationTimer() {
        tokenExpirationTimer?.invalidate()
        tokenExpirationTimer = nil
    }
    
    private func handleTokenExpiration() {
        DispatchQueue.main.async {
            self.showTokenExpiredToast = true
            self.clearTokenData()
        }
    }
    
    private func clearTokenData() {
        self.token = nil
        self.accessToken = ""
        self.isAuthenticated = false
        self.tokenExpirationDate = nil
        self.user = nil
        self.userEmail = nil
        self.userPhoto = nil
        
        UserDefaults.standard.removeObject(forKey: "auth_token")
        UserDefaults.standard.removeObject(forKey: "token_expiration_date")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "userPhotoURL")
        
        invalidateTokenExpirationTimer()
    }
    
    func checkAuthStatus() {
        if let expirationDate = tokenExpirationDate {
            if Date() >= expirationDate {
                handleTokenExpiration()
            } else {
                startTokenExpirationTimer()
            }
        } else if isAuthenticated {
            clearTokenData()
        }
    }
    
    // MARK: - Validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^(?=[A-Z0-9a-z._%+-]{1,64}@)(?!.*[-]{2,})[A-Z0-9a-z]([A-Z0-9a-z._%+-]*[A-Z0-9a-z])?@[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func isStrongPassword(_ password: String) -> Bool {
        guard password.count >= 8 else { return false }
        
        let uppercaseLetterRegex = ".*[A-Z]+.*"
        if !NSPredicate(format: "SELF MATCHES %@", uppercaseLetterRegex).evaluate(with: password) {
            return false
        }
        
        let lowercaseLetterRegex = ".*[a-z]+.*"
        if !NSPredicate(format: "SELF MATCHES %@", lowercaseLetterRegex).evaluate(with: password) {
            return false
        }
        
        let digitRegex = ".*[0-9]+.*"
        if !NSPredicate(format: "SELF MATCHES %@", digitRegex).evaluate(with: password) {
            return false
        }
        
        return true
    }
    
    // MARK: - Authentication
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
        } catch let error as APIError {
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
            self.errorMessage = APIError.unknownError.errorDescription
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
                    self.showLoginErrorToast = true
                    return (false, "ไม่ได้รับ access token จากเซิร์ฟเวอร์")
                }
                
                do {
                    let authResponse = try await authService.getAuthenticate(accessToken: accessToken)
                    
                    saveUserInfo(
                        email: email,
                        userId: authResponse.userId
                    )
                    saveAuthData(token: accessToken)
                    
                    self.showLoginSuccessToast = true
                    return (true, response.message ?? "เข้าสู่ระบบสำเร็จ")
                } catch {
                    self.errorMessage = "ไม่สามารถดึงข้อมูลผู้ใช้ได้"
                    self.showLoginErrorToast = true
                    return (false, "เกิดข้อผิดพลาดในการดึงข้อมูลผู้ใช้")
                }
            } else {
                self.errorMessage = response.message
                self.showLoginErrorToast = true
                return (false, response.message ?? "การเข้าสู่ระบบล้มเหลว")
            }
        } catch let error as APIError {
            self.isLoading = false
            
            switch error {
            case .serverError(let message):
                self.errorMessage = message
                self.showLoginErrorToast = true
                return (false, message)
            default:
                self.errorMessage = error.localizedDescription
                self.showLoginErrorToast = true
                return (false, error.localizedDescription)
            }
        } catch {
            self.isLoading = false
            self.errorMessage = APIError.unknownError.errorDescription
            self.showLoginErrorToast = true
            return (false, self.errorMessage ?? "เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ")
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        
        clearTokenData()
        user = nil
        resetToken = nil
        userEmail = nil
        userPhoto = nil
        
        self.showLogoutSuccessToast = true
    }
    
    // MARK: - Social Login
    @MainActor
    func socialLogin(email: String, method: String, token: String) async -> (success: Bool, message: String) {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let response = try await authService.socialLoginRequest(
                email: email,
                method: method,
                token: token
            )
            
            self.isLoading = false
            
            if response.code == 200 {
                guard let accessToken = response.access_token else {
                    self.errorMessage = "ไม่ได้รับ access token จากเซิร์ฟเวอร์"
                    self.showSocialLoginErrorToast = true
                    return (false, "ไม่ได้รับ access token จากเซิร์ฟเวอร์")
                }
                
                do {
                    let authResponse = try await authService.getAuthenticate(accessToken: accessToken)
                    
                    saveAuthData(token: accessToken)
                    
                    saveUserInfo(
                        email: email,
                        userId: authResponse.userId
                    )
                    
                    self.isAuthenticated = true
                    self.showSocialLoginSuccessToast = true
                    
                    return (true, "เข้าสู่ระบบสำเร็จ")
                } catch {
                    if let apiError = error as? APIError {
                        switch apiError {
                        case .serverError(let message):
                            self.errorMessage = "ไม่สามารถตรวจสอบข้อมูลผู้ใช้ได้: \(message)"
                        case .networkError:
                            self.errorMessage = "เกิดข้อผิดพลาดในการเชื่อมต่อเครือข่าย"
                        default:
                            self.errorMessage = "เกิดข้อผิดพลาดในการตรวจสอบ"
                        }
                    } else {
                        self.errorMessage = "เกิดข้อผิดพลาดที่ไม่คาดคิด"
                    }
                    
                    self.showSocialLoginErrorToast = true
                    return (false, self.errorMessage ?? "การยืนยันตัวตนล้มเหลว")
                }
            } else {
                self.errorMessage = response.message
                self.showSocialLoginErrorToast = true
                return (false, response.message)
            }
        } catch let error as APIError {
            switch error {
            case .serverError(let message):
                self.errorMessage = message
            case .networkError:
                self.errorMessage = "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้"
            default:
                self.errorMessage = error.localizedDescription
            }
            
            self.isLoading = false
            self.showSocialLoginErrorToast = true
            return (false, self.errorMessage ?? "เกิดข้อผิดพลาดในการเข้าสู่ระบบ")
        } catch {
            self.isLoading = false
            self.errorMessage = "เกิดข้อผิดพลาดที่ไม่คาดคิด"
            self.showSocialLoginErrorToast = true
            return (false, "เกิดข้อผิดพลาดที่ไม่คาดคิด")
        }
    }
    
    @MainActor
    func loginWithGoogle() async -> (success: Bool, message: String) {
        return await withCheckedContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(withPresenting: UIApplication.shared.getRootViewController()) { [weak self] result, error in
                Task { @MainActor in
                    if let error = error {
                        self?.handleLoginError(error: error, method: "Google")
                        self?.showSocialLoginErrorToast = true
                        continuation.resume(returning: (false, "Google login error: \(error.localizedDescription)"))
                        return
                    }
                    
                    guard let user = result?.user,
                          let idToken = user.idToken?.tokenString else {
                        self?.handleLoginError(error: NSError(domain: "LoginError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user found or missing ID token"]), method: "Google")
                        self?.showSocialLoginErrorToast = true
                        continuation.resume(returning: (false, "ไม่พบข้อมูลผู้ใช้หรือ token จาก Google"))
                        return
                    }
                    
                    let result = await self?.socialLogin(
                        email: user.profile?.email ?? "",
                        method: "google",
                        token: user.idToken?.tokenString ?? ""
                    )
                    
                    if let result = result, result.success {
                        self?.saveUserInfo(
                            email: user.profile?.email ?? "",
                            userId: user.userID,
                            photoURL: user.profile?.imageURL(withDimension: 200)?.absoluteString
                        )
                        continuation.resume(returning: (true, "เข้าสู่ระบบสำเร็จ"))
                    } else {
                        continuation.resume(returning: (false, result?.message ?? "การเข้าสู่ระบบล้มเหลว"))
                    }
                }
            }
        }
    }

    private func handleGoogleLogin(user: GIDGoogleUser) async -> (success: Bool, message: String) {
        guard let idToken = user.idToken?.tokenString else {
            handleLoginError(error: NSError(domain: "LoginError", code: -1, userInfo: [NSLocalizedDescriptionKey: "ID Token is missing"]), method: "Google")
            self.showSocialLoginErrorToast = true
            return (false, "ไม่พบ ID Token จาก Google")
        }
        
        let email = user.profile?.email ?? "Email not available"
        let photoURL = user.profile?.imageURL(withDimension: 200)?.absoluteString
        
        await saveUserInfo(
            email: email,
            userId: user.userID,
            photoURL: photoURL
        )
        
        return await socialLogin(email: email, method: "google", token: idToken)
    }
    
    func handleLoginError(error: Error, method: String) {
        DispatchQueue.main.async {
            self.errorMessage = "\(method) login error: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Password Reset
    @MainActor
    func requestPasswordReset(email: String) async -> (success: Bool, message: String) {
        if email.isEmpty {
            self.errorMessage = "กรุณากรอกอีเมล"
            return (false, "กรุณากรอกอีเมล")
        }
        
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
                self.showRequestResetPasswordSuccessToast = true
                return (true, "ส่งคำขอรีเซ็ตรหัสผ่านสำเร็จ กรุณาตรวจสอบอีเมล")
            } else {
                let errorMessage = "ไม่สามารถส่งคำขอรีเซ็ตรหัสผ่านได้ กรุณาลองใหม่อีกครั้ง"
                self.errorMessage = errorMessage
                self.showRequestResetPasswordErrorToast = true
                return (false, errorMessage)
            }
        } catch let error as APIError {
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
            case .invalidURL, .invalidResponse, .decodingError, .unknownError :
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

    @MainActor
    func resetPassword(newPassword: String) async -> (success: Bool, message: String) {
        guard let token = self.resetToken else {
            self.errorMessage = "ไม่พบโทเค็นสำหรับรีเซ็ตรหัสผ่าน กรุณาส่งคำขอรีเซ็ตใหม่"
            self.showResetPasswordErrorToast = true
            return (false, "ไม่พบโทเค็นสำหรับรีเซ็ตรหัสผ่าน กรุณาส่งคำขอรีเซ็ตใหม่")
        }
        
        if !isStrongPassword(newPassword) {
            self.errorMessage = "รหัสผ่านต้องมี 8 ตัวอักษรขึ้นไป ประกอบด้วยตัวพิมพ์ใหญ่ ตัวพิมพ์เล็ก และตัวเลข"
            self.showInvalidCredentialsToast = true
            return (false, "รหัสผ่านไม่ตรงตามเงื่อนไข")
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let response = try await authService.resetPassword(newPassword: newPassword, token: token)
            
            self.isLoading = false
            
            if response.code == 200 {
                self.resetToken = nil
                self.showResetPasswordSuccessToast = true
                return (true, "รีเซ็ตรหัสผ่านสำเร็จ")
            } else {
                let errorMessage = "ไม่สามารถรีเซ็ตรหัสผ่านได้ กรุณาลองใหม่อีกครั้ง"
                self.errorMessage = errorMessage
                self.showResetPasswordErrorToast = true
                return (false, errorMessage)
            }
        } catch let error as APIError {
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

// MARK: - Extensions
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
