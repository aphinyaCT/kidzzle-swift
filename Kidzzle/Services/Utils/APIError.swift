//
//  APIError.swift
//  Kidzzle
//
//  Created by aynnipa on 9/4/2568 BE.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError
    case decodingError
    case serverError(message: String)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL ไม่ถูกต้อง"
        case .invalidResponse:
            return "การตอบกลับจากเซิร์ฟเวอร์ไม่ถูกต้อง"
        case .networkError:
            return "เกิดปัญหาในการเชื่อมต่อเครือข่าย"
        case .decodingError:
            return "ไม่สามารถอ่านข้อมูลที่ได้รับจากเซิร์ฟเวอร์"
        case .serverError(let message):
            return "ข้อผิดพลาดจากเซิร์ฟเวอร์: \(message)"
        case .unknownError:
            return "เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ"
        }
    }
}

struct ErrorResponse: Codable {
    let code: Int
    let message: String
}
