//
//  AuthAPIService.swift
//  Kidzzle
//
//  Created by aynnipa on 23/3/2568 BE.
//

import Foundation
//import GoogleSignIn
//import LineSDK

class AuthAPIService {
    private let baseURL = "https://kidzzle-api-kidzzle-807625438905.asia-southeast1.run.app/api/v1"
    
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
            throw AuthError.invalidURL
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
                throw AuthError.invalidResponse
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
                    throw AuthError.serverError(errorResponse.message ?? "No Message")
                } catch {
                    throw AuthError.serverError("Server error: \(httpResponse.statusCode)")
                }
            }
            
            do {
                return try JSONDecoder().decode(R.self, from: data)
            } catch {
                print("❌ Decoding Error: \(error)")
                throw AuthError.decodingError(error)
            }
        } catch let error as AuthError {
            throw error
        } catch {
            print("❌ Network Error: \(error)")
            throw AuthError.networkError(error)
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
            throw AuthError.invalidURL
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
                throw AuthError.invalidResponse
            }
            
            // Debug
            print("Response status code: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response body: \(responseString)")
            }
            
            if httpResponse.statusCode != 200 {
                if let errorResponse = try? JSONDecoder().decode(ResetPasswordResponse.self, from: data) {
                    throw AuthError.serverError(errorResponse.message)
                } else {
                    throw AuthError.serverError("Server error: \(httpResponse.statusCode)")
                }
            }
            
            do {
                return try JSONDecoder().decode(R.self, from: data)
            } catch {
                print("Decoding error: \(error)")
                throw AuthError.decodingError(error)
            }
        } catch let error as AuthError {
            throw error
        } catch {
            throw AuthError.networkError(error)
        }
    }
    
}
