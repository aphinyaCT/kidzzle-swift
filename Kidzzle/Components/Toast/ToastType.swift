//
//  ToastType.swift
//  Kidzzle
//
//  Created by aynnipa on 1/4/2568 BE.
//


import SwiftUI

// MARK: - Toast Type
enum ToastType {
    case success
    case error
    case info
    
    var color: Color {
        switch self {
        case .success: return Color.greenMint
        case .error: return Color.coralRed
        case .info: return Color.deepBlue
        }
    }
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "exclamationmark.circle.fill"
        case .info: return "info.circle.fill"
        }
    }
}

// MARK: - Toast Case
enum ToastCase {
    case loginSuccess
    case registerSuccess
    case loginError
    case registerError
    case requestResetPasswordSuccess
    case requestResetPasswordError
    case resetPasswordSuccess
    case resetPasswordError
    case logoutSuccess
    case invalidCredentials
    case tokenExpired
    case assessmentSuccess
    
    var message: String {
        switch self {
        case .loginSuccess:
            return "เข้าสู่ระบบสำเร็จ"
        case .loginError:
            return "อีเมลหรือรหัสผ่านไม่ถูกต้อง"
        case .registerSuccess:
            return "สมัครสมาชิกสำเร็จ"
        case .registerError:
            return "อีเมลถูกใช้งานแล้ว"
        case .requestResetPasswordSuccess:
            return "ส่งคำขอรีเซ็ตรหัสผ่านสำเร็จ"
        case .requestResetPasswordError:
            return "ส่งคำขอรีเซ็ตรหัสผ่านไม่สำเร็จ ลองอีกครั้ง"
        case .resetPasswordSuccess:
            return "เปลี่ยนรหัสผ่านสำเร็จ ลองเข้าสู่ระบบอีกครั้ง"
        case .resetPasswordError:
            return "เปลี่ยนรหัสผ่านไม่สำเร็จ ลองอีกครั้ง"
        case .logoutSuccess:
            return "ออกจากระบบสำเร็จ"
        case .invalidCredentials:
            return "รูปแบบอีเมลหรือรหัสผ่านไม่ถูกต้อง"
        case .tokenExpired:
            return "เซสชั่นหมดอายุ กรุณาเข้าสู่ระบบอีกครั้ง"
        case .assessmentSuccess:
            return "บันทึกการประเมินเสร็จสิ้น"
        }
    }
    
    var type: ToastType {
        switch self {
        case .loginError, .registerError, .invalidCredentials, .resetPasswordError, .requestResetPasswordError, .tokenExpired:
            return .error
        case .loginSuccess, .registerSuccess, .logoutSuccess, .resetPasswordSuccess, .requestResetPasswordSuccess, .assessmentSuccess:
            return .success
        }
    }
}
