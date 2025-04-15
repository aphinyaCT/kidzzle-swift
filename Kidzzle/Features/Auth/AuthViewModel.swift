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
    private var tokenExpirationTimer: Timer?
    private let tokenExpirationInterval: TimeInterval = 3600
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    @Published var user: User?
    @Published var token: String?
    @Published var userId: String?
    @Published var resetToken: String?
    @Published var accessToken: String = ""
    @Published var tokenExpirationDate: Date?
    @Published var userEmail: String?  // เพิ่มตัวแปรสำหรับเก็บอีเมล
    @Published var userPhoto: String?  // เพิ่มตัวแปรสำหรับเก็บ URL รูปภาพ
    
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
    
    // MARK: Token Expiration Toast
    @Published var showTokenExpiredToast = false
    
    init() {
        // โหลดข้อมูลที่บันทึกไว้เมื่อเริ่มต้น
        loadSavedUserData()
    }
    
    deinit {
        invalidateTokenExpirationTimer()
    }
    
    // เก็บข้อมูลการล็อกอิน
    func saveAuthData(token: String) {
        // สร้าง expiration date (1 ชั่วโมงนับจากตอนนี้)
        let expirationDate = Date().addingTimeInterval(tokenExpirationInterval)
        
        // บันทึกลง UserDefaults
        UserDefaults.standard.set(token, forKey: "auth_token")
        UserDefaults.standard.set(expirationDate.timeIntervalSince1970, forKey: "token_expiration_date")
        
        print("Token saved: \(token)")
        print("Token will expire at: \(expirationDate)")
        
        DispatchQueue.main.async {
            self.token = token
            self.accessToken = token
            self.isAuthenticated = true
            self.tokenExpirationDate = expirationDate
            self.errorMessage = nil
            
            // เริ่มตั้งเวลาหมดอายุ token
            self.startTokenExpirationTimer()
        }
    }
    
    private func loadSavedUserData() {
        if let token = UserDefaults.standard.string(forKey: "auth_token"),
           let expirationTimeInterval = UserDefaults.standard.object(forKey: "token_expiration_date") as? TimeInterval {
            
            let expirationDate = Date(timeIntervalSince1970: expirationTimeInterval)
            
            // ตรวจสอบว่า token ยังไม่หมดอายุ
            if expirationDate > Date() {
                self.token = token
                self.accessToken = token
                self.isAuthenticated = true
                self.tokenExpirationDate = expirationDate
                
                // โหลดข้อมูลผู้ใช้
                self.userEmail = UserDefaults.standard.string(forKey: "userEmail")
                self.userId = UserDefaults.standard.string(forKey: "userId")
                self.userPhoto = UserDefaults.standard.string(forKey: "userPhotoURL")
                
                // สร้าง User object
                if let email = self.userEmail {
                    self.user = User(
                        id: self.userId ?? "",
                        email: email,
                        photo: self.userPhoto
                    )
                }
                
                // เริ่มตั้งเวลาเพื่อตรวจสอบการหมดอายุของ token
                startTokenExpirationTimer()
            } else {
                // ถ้า token หมดอายุแล้ว ให้ลบข้อมูลใน UserDefaults
                print("Token has expired. User needs to log in again.")
                clearTokenData()
            }
        }
    }
    
    private func startTokenExpirationTimer() {
        // ยกเลิก timer ตัวเก่าก่อน (ถ้ามี)
        invalidateTokenExpirationTimer()
        
        guard let expirationDate = tokenExpirationDate else { return }
        
        // คำนวณเวลาที่เหลือจนกว่า token จะหมดอายุ
        let remainingTime = expirationDate.timeIntervalSinceNow
        
        // ถ้าเหลือเวลาน้อยกว่า 0 หรือเท่ากับ 0 แสดงว่า token หมดอายุแล้ว
        if remainingTime <= 0 {
            handleTokenExpiration()
            return
        }
        
        print("Token will expire in \(Int(remainingTime)) seconds")
        
        // ตั้งเวลาใหม่
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
            print("Token has expired at: \(Date())")
            
            // แจ้งเตือนผู้ใช้ว่า session หมดอายุแล้ว
            self.showTokenExpiredToast = true
            
            // ล้างข้อมูล token
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
    
    // ตรวจสอบสถานะการเข้าสู่ระบบและความถูกต้องของ token
    func checkAuthStatus() {
        if let expirationDate = tokenExpirationDate {
            if Date() >= expirationDate {
                // Token หมดอายุแล้ว
                handleTokenExpiration()
            } else {
                // Token ยังใช้งานได้ อัพเดท timer
                startTokenExpirationTimer()
            }
        } else if isAuthenticated {
            // มีการเข้าสู่ระบบแต่ไม่มีข้อมูลวันหมดอายุ (กรณีที่ไม่ปกติ)
            clearTokenData()
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
        
        print("Debug - After saving:")
        print("UserDefaults email: \(UserDefaults.standard.string(forKey: "userEmail") ?? "nil")")
        print("UserDefaults userId: \(UserDefaults.standard.string(forKey: "userId") ?? "nil")")
        print("Published userEmail: \(self.userEmail ?? "nil")")
        print("Published userId: \(self.userId ?? "nil")")
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
                    print("👤 User ID: \(authResponse.userId)")
                    
                    saveUserInfo(
                        email: email,
                        userId: authResponse.userId
                    )
                    saveAuthData(token: accessToken)
                    
                    self.showLoginSuccessToast = true
                    return (true, response.message ?? "เข้าสู่ระบบสำเร็จ")
                } catch {
                    print("❌ Authentication error: \(error)")
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
                    print("❌ No access token received from server")
                    self.errorMessage = "ไม่ได้รับ access token จากเซิร์ฟเวอร์"
                    self.showSocialLoginErrorToast = true
                    return (false, "ไม่ได้รับ access token จากเซิร์ฟเวอร์")
                }
                
                do {
                    let authResponse = try await authService.getAuthenticate(accessToken: accessToken)
                    
                    print("🔒 Authentication Successful")
                    print("👤 User ID: \(authResponse.userId)")
                    
                    saveAuthData(token: accessToken)
                    
                    saveUserInfo(
                        email: email,
                        userId: authResponse.userId
                    )
                    
                    self.isAuthenticated = true
                    self.showSocialLoginSuccessToast = true
                    
                    return (true, "เข้าสู่ระบบสำเร็จ")
                } catch {
                    print("❌ Authentication Error: \(error)")
                    
                    // Detailed error handling for authentication
                    if let apiError = error as? APIError {
                        switch apiError {
                        case .serverError(let message):
                            print("🚨 Server Error: \(message)")
                            self.errorMessage = "ไม่สามารถตรวจสอบข้อมูลผู้ใช้ได้: \(message)"
                        case .networkError:
                            print("🌐 Network Error")
                            self.errorMessage = "เกิดข้อผิดพลาดในการเชื่อมต่อเครือข่าย"
                        default:
                            print("🔧 Other Authentication Error")
                            self.errorMessage = "เกิดข้อผิดพลาดในการตรวจสอบ"
                        }
                    } else {
                        print("❓ Unknown Error: \(error)")
                        self.errorMessage = "เกิดข้อผิดพลาดที่ไม่คาดคิด"
                    }
                    
                    self.showSocialLoginErrorToast = true
                    return (false, self.errorMessage ?? "การยืนยันตัวตนล้มเหลว")
                }
            } else {
                print("❌ Social Login Failed: \(response.message)")
                self.errorMessage = response.message
                self.showSocialLoginErrorToast = true
                return (false, response.message)
            }
        } catch let error as APIError {
            print("❌ API Error in Social Login: \(error)")
            
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
            print("❌ Unexpected Error in Social Login: \(error)")
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
                    
                    print("Debug - Google Sign In Success")
                    print("ID Token: \(idToken)")
                    print("Email: \(user.profile?.email ?? "N/A")")
                    print("User ID: \(user.userID ?? "N/A")")
                    
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
        _ = user.accessToken.tokenString
        
        guard let idToken = user.idToken?.tokenString else {
            handleLoginError(error: NSError(domain: "LoginError", code: -1, userInfo: [NSLocalizedDescriptionKey: "ID Token is missing"]), method: "Google")
            self.showSocialLoginErrorToast = true
            return (false, "ไม่พบ ID Token จาก Google")
        }
        
        let email = user.profile?.email ?? "Email not available"
        let photoURL = user.profile?.imageURL(withDimension: 200)?.absoluteString
        
        // บันทึกข้อมูลผู้ใช้
        await saveUserInfo(
            email: email,
            userId: user.userID,
            photoURL: photoURL
        )
        
        // Proceed with social login
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
        
        clearTokenData()
        user = nil
        resetToken = nil
        userEmail = nil
        userPhoto = nil
        
        self.showLogoutSuccessToast = true
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
