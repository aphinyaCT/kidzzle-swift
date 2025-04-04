//
//  ChildDevelopmentAPIService.swift
//  Kidzzle
//
//  Created by aynnipa on 28/3/2568 BE.
//

import Foundation

class ChildDevelopmentAPIService {
    private let baseURL = "https://kidzzle-api-kidzzle-807625438905.asia-southeast1.run.app/api/v1"
    
    let assessmentTypes = [
        "ASSMTT_1": "DSPM",
        "ASSMTT_2": "DAIM"
    ]
    
    func postData<T: Decodable, U: Encodable>(endpoint: String, body: U) async throws -> T {
        // สร้าง URL โดยรวม baseURL และ endpoint
        let urlString = "\(baseURL)\(endpoint)"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        // สร้าง request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // เพิ่ม authorization token ถ้ามี
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // แปลงข้อมูลเป็น JSON
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            throw APIError.decodingError(error)
        }
        
        // ส่ง request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // แสดงข้อมูลดิบเพื่อการดีบัก
        if let responseString = String(data: data, encoding: .utf8) {
            print("Raw API Response: \(responseString)")
        }
        
        // ตรวจสอบ response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // ตรวจสอบสถานะการตอบกลับ
        if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
            // แปลงข้อมูล JSON เป็น Model
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                print("Decoding error: \(error)")
                throw APIError.decodingError(error)
            }
        } else {
            // จัดการข้อผิดพลาด
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.message)
            } else {
                throw APIError.httpError(httpResponse.statusCode)
            }
        }
    }
    
    func fetchData<T: Decodable>(endpoint: String, parameters: [String: String]? = nil) async throws -> T {
        // สร้าง URL โดยรวม baseURL และ endpoint
        let urlString = "\(baseURL)\(endpoint)"
        
        // สร้าง URLComponents เพื่อจัดการกับ query parameters
        var components = URLComponents(string: urlString)!
        
        // เพิ่ม query parameters ถ้ามี
        if let parameters = parameters {
            components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        // สร้าง request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // เพิ่ม authorization token ถ้ามี
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // ส่ง request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // แสดงข้อมูลดิบเพื่อการดีบัก
        if let responseString = String(data: data, encoding: .utf8) {
            print("Raw API Response: \(responseString)")
        }
        
        // ตรวจสอบ response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // ตรวจสอบสถานะการตอบกลับ
        if httpResponse.statusCode == 200 {
            // แปลงข้อมูล JSON เป็น Model
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                print("Decoding error: \(error)")
                throw APIError.decodingError(error)
            }
        } else {
            // จัดการข้อผิดพลาด
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.message)
            } else {
                throw APIError.httpError(httpResponse.statusCode)
            }
        }
    }
        
}
