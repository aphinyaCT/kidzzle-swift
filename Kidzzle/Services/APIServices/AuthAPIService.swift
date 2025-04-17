//
//  AuthAPIService.swift
//  Kidzzle
//
//  Created by aynnipa on 23/3/2568 BE.
//

import Foundation

class AuthAPIService {
    private let baseURL = "https://kidzzle-api-807625438905.asia-southeast1.run.app/api/v1"
    
    func registerRequest(email: String, password: String) async throws -> RegisterResponse {
        let registerURL = "\(baseURL)/users/register"
        
        let request = RegisterRequest(
            email: email,
            password: password
        )
        
        return try await sendPostRequest(to: registerURL, with: request)
    }

    func loginRequest(email: String, password: String) async throws -> LoginResponse {
        let loginURL = "\(baseURL)/users/login"
        
        let request = LoginRequest(
            email: email,
            password: password
        )
        
        return try await sendPostRequest(to: loginURL, with: request)
    }
    
    func socialLoginRequest(email: String, method: String, token: String) async throws -> SocialAuthResponse {
        let loginURL = "\(baseURL)/users/login/social"
        
        let request = SocialLoginRequest(
            email: email,
            method: method,
            token: token
        )
        
        return try await sendPostRequest(to: loginURL, with: request)
    }
    
    //MARK: ส่ง request ทั่วไป
    private func sendPostRequest<T: Encodable, R: Decodable>(to urlString: String, with body: T) async throws -> R {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            throw APIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // แปลง body เป็น JSON
        let jsonData = try JSONEncoder().encode(body)
        urlRequest.httpBody = jsonData
        
        // Debug
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("✉️ Request Body: \(jsonString)")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP Response")
                throw APIError.invalidResponse
            }
            
            // Debug
            print("📥 Response status code: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response body: \(responseString)")
            }
            
            // แยกการจัดการ Error ตาม Response Type
            if httpResponse.statusCode != 200 {
                // พยายามแปลงเป็น Error Response
                do {
                    let errorResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                    throw APIError.serverError(message: errorResponse.message ?? "No Message")
                } catch {
                    throw APIError.serverError(message: "Server error: \(httpResponse.statusCode)")
                }
            }
            
            do {
                return try JSONDecoder().decode(R.self, from: data)
            } catch {
                print("❌ Decoding Error: \(error)")
                throw APIError.decodingError
            }
        } catch let error as APIError {
            throw error
        } catch {
            print("❌ Network Error: \(error)")
            throw APIError.networkError
        }
    }
    
    //MARK: Utility เพื่อถอดรหัส JWT token
    func decodeJWTToken(_ token: String) -> [String: Any]? {
        let segments = token.components(separatedBy: ".")
        guard segments.count > 1 else { return nil }
        
        let base64String = segments[1]
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let padded = base64String.padding(toLength: ((base64String.count + 3) / 4) * 4,
                                          withPad: "=",
                                          startingAt: 0)
        
        guard let data = Data(base64Encoded: padded) else { return nil }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            return json as? [String: Any]
        } catch {
            print("Failed to decode JWT token: \(error)")
            return nil
        }
    }
    
    //MARK: Request Reset Password
    func requestResetPassword(email: String) async throws -> RequestResetPasswordResponse {
        let resetURL = "\(baseURL)/users/request-reset-password"
        
        let request = RequestResetPasswordRequest(
            email: email
        )
        
        return try await sendPostRequest(to: resetURL, with: request)
    }
    
    //MARK: Reset Password
    func resetPassword(newPassword: String, token: String) async throws -> ResetPasswordResponse {
        let resetURL = "\(baseURL)/users/reset-password"
        
        let request = ResetPasswordRequest(
            password: newPassword,
            token: token
        )
        
        return try await sendPutRequest(to: resetURL, with: request)
    }
    
    //MARK: Send PUT request
    private func sendPutRequest<T: Encodable, R: Decodable>(to urlString: String, with body: T) async throws -> R {
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // แปลง body เป็น JSON
        let jsonData = try JSONEncoder().encode(body)
        urlRequest.httpBody = jsonData
        
        // Debug
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("Request Body: \(jsonString)")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            // Debug
            print("Response status code: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response body: \(responseString)")
            }
            
            if httpResponse.statusCode != 200 {
                if let errorResponse = try? JSONDecoder().decode(ResetPasswordResponse.self, from: data) {
                    throw APIError.serverError(message: errorResponse.message)
                } else {
                    throw APIError.serverError(message: "Server error: \(httpResponse.statusCode)")
                }
            }
            
            do {
                return try JSONDecoder().decode(R.self, from: data)
            } catch {
                print("Decoding error: \(error)")
                throw APIError.decodingError
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError
        }
    }
    
    func getAuthenticate(accessToken: String) async throws -> AuthResponse {
        print("🔍 Access Token for Authentication: \(accessToken)")
        
        guard let url = URL(string: "\(baseURL)/users/authenticate") else {
            throw APIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        print("🔍 Sending authenticate request to: \(url)")
        print("🔍 Using Authorization header: Bearer \(accessToken)")
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            print("✅ Response Status Code: \(httpResponse.statusCode)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("✅ Response Body: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let decoder = JSONDecoder()
                
                do {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("🔍 Raw JSON for decoding: \(jsonString)")
                    }
                    
                    let authResponse = try decoder.decode(AuthResponse.self, from: data)
                    print("✅ Successfully decoded AuthResponse")
                    return authResponse
                    
                } catch {
                    print("❌ Decode Error Details:")
                    print("Error Type: \(type(of: error))")
                    print("Error: \(error)")
                    print("Error Description: \(error.localizedDescription)")
                    
                    throw APIError.decodingError
                }
                
            case 404:
                throw APIError.serverError(message: "ไม่พบข้อมูลผู้ใช้")
                
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
}
