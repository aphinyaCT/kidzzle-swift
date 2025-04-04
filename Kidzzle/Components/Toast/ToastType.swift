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
        case .success: return Color.green
        case .error: return Color.red
        case .info: return Color.blue
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
    case passwordResetRequestSuccess
    case passwordChangeSuccess
    case userNotFound
    
    var message: String {
        switch self {
        case .loginSuccess:
            return "เข้าสู่ระบบสำเร็จ"
        case .loginError:
            return "อีเมลหรือรหัสผ่านไม่ถูกต้อง"
        case .registerSuccess:
            return "สมัครสมาชิกสำเร็จ"
        case .registerError:
            return "อีเมลถูกใช้งานแล้วหรือรูปแบบอีเมลไม่ถูกต้อง"
        case .passwordResetRequestSuccess:
            return "ส่งคำขอรีเซ็ตรหัสผ่านสำเร็จ"
        case .passwordChangeSuccess:
            return "เปลี่ยนรหัสผ่านสำเร็จ ลองเข้าสู่ระบบอีกครั้ง"
        case .userNotFound:
            return "ไม่พบอีเมลนี้ในระบบ"
        }
    }
    
    var type: ToastType {
        switch self {
        case .loginError, .userNotFound, .registerError:
            return .error
        case .loginSuccess, .registerSuccess, .passwordResetRequestSuccess, .passwordChangeSuccess:
            return .success
        }
    }
}
