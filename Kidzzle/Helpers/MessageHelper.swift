//
//  MessageHelper.swift
//  Kidzzle
//
//  Created by aynnipa on 1/4/2568 BE.
//


import Foundation

struct MessageHelper {
    static func getMessageForResponseCode(code: Int, action: String) -> String {
        switch code {
        case 200:
            // สำเร็จ
            switch action {
            case "login":
                return "เข้าสู่ระบบสำเร็จ"
            case "register":
                return "ลงทะเบียนสำเร็จ"
            case "requestReset":
                return "ส่งคำขอเปลี่ยนรหัสผ่านสำเร็จ"
            case "resetPassword":
                return "เปลี่ยนรหัสผ่านสำเร็จ"
            case "logout":
                return "ออกจากระบบสำเร็จ"
            default:
                return "ดำเนินการสำเร็จ"
            }
            
        case 400:
            // ข้อมูลไม่ถูกต้อง
            switch action {
            case "login":
                return "อีเมลหรือรหัสผ่านไม่ถูกต้อง"
            case "register":
                return "ข้อมูลลงทะเบียนไม่ถูกต้อง กรุณาตรวจสอบข้อมูลของคุณ"
            case "requestReset":
                return "ไม่สามารถส่งคำขอเปลี่ยนรหัสผ่านได้ กรุณาตรวจสอบอีเมลของคุณ"
            case "resetPassword":
                return "ไม่สามารถเปลี่ยนรหัสผ่านได้ กรุณาตรวจสอบข้อมูลของคุณ"
            default:
                return "ข้อมูลไม่ถูกต้อง กรุณาตรวจสอบและลองใหม่อีกครั้ง"
            }
            
        case 401:
            // ไม่มีสิทธิ์เข้าถึง
            switch action {
            case "login":
                return "อีเมลหรือรหัสผ่านไม่ถูกต้อง"
            case "requestReset":
                return "ไม่พบอีเมลนี้ในระบบ"
            default:
                return "ไม่มีสิทธิ์เข้าถึง หรือเซสชันหมดอายุ กรุณาเข้าสู่ระบบใหม่"
            }
            
        case 404:
            // ไม่พบข้อมูล
            switch action {
            case "login":
                return "ไม่พบบัญชีผู้ใช้นี้ในระบบ"
            case "requestReset":
                return "ไม่พบอีเมลนี้ในระบบ"
            default:
                return "ไม่พบข้อมูลที่ต้องการ"
            }
            
        case 409:
            // ข้อมูลซ้ำ
            switch action {
            case "register":
                return "อีเมลนี้มีผู้ใช้งานแล้ว"
            default:
                return "ข้อมูลมีความขัดแย้งกับระบบ"
            }
            
        case 429:
            // ส่งคำขอมากเกินไป
            switch action {
            case "login":
                return "คุณพยายามเข้าสู่ระบบบ่อยเกินไป กรุณารอสักครู่แล้วลองใหม่"
            case "requestReset":
                return "คุณส่งคำขอเปลี่ยนรหัสผ่านบ่อยเกินไป กรุณารอสักครู่แล้วลองใหม่"
            default:
                return "คุณส่งคำขอบ่อยเกินไป กรุณารอสักครู่แล้วลองใหม่"
            }
            
        case 500, 502, 503, 504:
            // ข้อผิดพลาดฝั่งเซิร์ฟเวอร์
            return "เกิดข้อผิดพลาดในระบบ กรุณาลองใหม่ภายหลัง"
            
        default:
            return "เกิดข้อผิดพลาด (รหัส: \(code))"
        }
    }
}
