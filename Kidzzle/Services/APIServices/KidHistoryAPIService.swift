//
//  KidHistoryAPIService.swift
//  Kidzzle
//
//  Created by aynnipa on 7/4/2568 BE.
//

import Foundation

class KidHistoryAPIService {
    
    private let baseURL = "https://kidzzle-api-807625438905.asia-southeast1.run.app/api/v1"
    
    func createKidHistory(request: CreateKidHistoryRequest, accessToken: String) async throws -> CreateKidHistoryResponse {
        
        guard let url = URL(string: "\(baseURL)/kids/create") else {
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
                print("✅ Response Body: \(responseString)")
                
                if responseString == "null" {
                    print("ℹ️ Server returned null - empty response")
                    return CreateKidHistoryResponse(code: httpResponse.statusCode, message: "สร้างข้อมูลสำเร็จ")
                }
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                if data.isEmpty || (String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) == "null") {
                    print("⚠️ Empty or null response with success status code")
                    return CreateKidHistoryResponse(code: httpResponse.statusCode, message: "สร้างข้อมูลสำเร็จ แต่ไม่ได้รับข้อมูลตอบกลับ")
                }
                
                do {
                    let decodedResponse = try decoder.decode(CreateKidHistoryResponse.self, from: data)
                    return decodedResponse
                } catch {
                    print("⚠️ Decode Failed: \(error)")
                    return CreateKidHistoryResponse(code: httpResponse.statusCode, message: "สร้างข้อมูลสำเร็จ แต่ไม่สามารถอ่านข้อมูลตอบกลับได้")
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
    
    func getKidHistory(accessToken: String, pregnantId: String) async throws -> [KidHistoryData] {
        guard let url = URL(string: "\(baseURL)/kids/\(pregnantId)") else {
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
                print("✅ Response Body: \(responseString)")
                
                if responseString == "null" {
                    print("ℹ️ Server returned null - no kid history data found")
                    return []
                }
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let decoder = JSONDecoder()
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔍 Raw JSON for decoding: \(jsonString)")
                }

                if let kidHistoryArray = try? decoder.decode([KidHistoryData].self, from: data) {
                    print("✅ Successfully decoded as Array")
                    return kidHistoryArray
                }
                
                let responseWrapper = try decoder.decode(KidHistoryResponse.self, from: data)
                print("✅ Successfully decoded as KidHistoryResponse")
                return responseWrapper.data
                
            case 404:
                throw APIError.serverError(message: "ไม่พบข้อมูลประวัติลูกน้อย")
                
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
        request: UpdateKidHistoryRequest
    ) async throws -> CreateKidHistoryResponse {
        
        guard let url = URL(string: "\(baseURL)/kids/\(request.kidId)") else {
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
                    return CreateKidHistoryResponse(code: httpResponse.statusCode, message: "อัปเดตข้อมูลสำเร็จ")
                }
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode(CreateKidHistoryResponse.self, from: data)
                
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
    ) async throws -> CreateKidHistoryResponse {
        guard let url = URL(string: "\(baseURL)/kids/\(id)") else {
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
                    return CreateKidHistoryResponse(code: httpResponse.statusCode, message: "ลบข้อมูลสำเร็จ")
                }
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                let decodedResponse = try decoder.decode(CreateKidHistoryResponse.self, from: data)
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
