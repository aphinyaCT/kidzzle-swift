//
//  MotherPregnantAPIService.swift
//  Kidzzle
//
//  Created by aynnipa on 8/4/2568 BE.
//

import Foundation

class MotherPregnantAPIService {
    
    private let baseURL = "https://kidzzle-api-807625438905.asia-southeast1.run.app/api/v1"
    
    func createMotherPregnant(request: CreateMotherPregnantRequest, accessToken: String) async throws -> CreateMotherPregnantResponse{
        
        guard let url = URL(string: "\(baseURL)/mother-pregnants/create") else {
            throw APIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        do {
            let jsonData = try encoder.encode(request)
            urlRequest.httpBody = jsonData
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("✅ Request Body: \(jsonString)")
            }
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            print("✅ Response Status Code: \(httpResponse.statusCode)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                if responseString == "null" {
                    print("ℹ️ Server returned null - empty response")
                    return CreateMotherPregnantResponse(code: httpResponse.statusCode, message: "สร้างข้อมูลสำเร็จ")
                }
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                if data.isEmpty || (String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) == "null") {
                    print("⚠️ Empty or null response with success status code")
                    return CreateMotherPregnantResponse(code: httpResponse.statusCode, message: "สร้างข้อมูลสำเร็จ แต่ไม่ได้รับข้อมูลตอบกลับ")
                }
                
                do {
                    let decodedResponse = try decoder.decode(CreateMotherPregnantResponse.self, from: data)
                    return decodedResponse
                } catch {
                    print("⚠️ Decode Failed: \(error)")
                    return CreateMotherPregnantResponse(code: httpResponse.statusCode, message: "สร้างข้อมูลสำเร็จ แต่ไม่สามารถอ่านข้อมูลตอบกลับได้")
                }
                
            case 400...:
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                    throw APIError.serverError(message: errorResponse.message)
                } else {
                    throw APIError.serverError(message: "เกิดข้อผิดพลาดที่เซิร์ฟเวอร์")
                }
                
            default:
                throw APIError.invalidResponse
            }
            
        } catch let error as APIError {
            throw error
        } catch {
            print("❌ Network Error: \(error)")
            throw APIError.networkError
        }
    }
    
    func getMotherPregnant(accessToken: String) async throws -> [MotherPregnantData] {
        guard let url = URL(string: "\(baseURL)/mother-pregnants") else {
            throw APIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            print("✅ Response Status Code: \(httpResponse.statusCode)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                if responseString == "null" {
                    print("ℹ️ Server returned null - no mother pregnant data found")
                    return []
                }
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let decoder = JSONDecoder()
                
                do {
                    
                    return try decoder.decode([MotherPregnantData].self, from: data)
                    
                } catch {
                    throw APIError.serverError(message: "ไม่สามารถอ่านข้อมูลที่ได้รับจากเซิร์ฟเวอร์ได้ (null)")
                }
                
            case 404:
                throw APIError.serverError(message: "ไม่พบข้อมูลประวัติการตั้งครรภ์")
                
            case 400...:
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                    throw APIError.serverError(message: errorResponse.message)
                } else {
                    throw APIError.serverError(message: "เกิดข้อผิดพลาดที่เซิร์ฟเวอร์")
                }
                
            default:
                throw APIError.invalidResponse
            }
            
        } catch let error as APIError {
            throw error
        } catch {
            print("❌ Network Error: \(error)")
            throw APIError.networkError
        }
    }
    
    func updateKidHistory(
        accessToken: String,
        pregnantId: String,
        request: UpdateMotherPregnantRequest
    ) async throws -> CreateMotherPregnantResponse {
        
        guard let url = URL(string: "\(baseURL)/mother-pregnants/\(pregnantId)") else {
            throw APIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        do {
            let jsonData = try encoder.encode(request)
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📦 Request JSON: \(jsonString)")
            }
            
            urlRequest.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            print("📥 Response Status Code: \(httpResponse.statusCode)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response Body: \(responseString)")
                
                if responseString == "null" {
                    print("ℹ️ Server returned null - empty response")
                    return CreateMotherPregnantResponse(code: httpResponse.statusCode, message: "อัปเดตข้อมูลสำเร็จ")
                }
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode(CreateMotherPregnantResponse.self, from: data)
                
            case 400...:
                let decoder = JSONDecoder()
                if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                    throw APIError.serverError(message: errorResponse.message)
                } else {
                    throw APIError.serverError(message: "เกิดข้อผิดพลาดในการอัปเดตข้อมูล")
                }
                
            default:
                throw APIError.invalidResponse
            }
        } catch let error as APIError {
            throw error
        } catch {
            print("❌ Full Error Details: \(error)")
            throw APIError.networkError
        }
    }

    
    func deleteKidHistory(
        id: String,
        accessToken: String
    ) async throws -> CreateMotherPregnantResponse {
        guard let url = URL(string: "\(baseURL)/mother-pregnants/\(id)") else {
            throw APIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response Body: \(responseString)")
                
                if responseString == "null" {
                    print("ℹ️ Server returned null - empty response")
                    return CreateMotherPregnantResponse(code: httpResponse.statusCode, message: "ลบข้อมูลสำเร็จ")
                }
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                let decodedResponse = try decoder.decode(CreateMotherPregnantResponse.self, from: data)
                return decodedResponse
                
            case 400...:
                let decoder = JSONDecoder()
                if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                    throw APIError.serverError(message: errorResponse.message)
                } else {
                    throw APIError.serverError(message: "เกิดข้อผิดพลาดในการลบข้อมูล")
                }
                
            default:
                throw APIError.invalidResponse
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError
        }
    }
}
