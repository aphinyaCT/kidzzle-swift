//
//  ChildDevelopmentAPIService.swift
//  Kidzzle
//
//  Created by aynnipa on 9/4/2568 BE.
//

import Foundation

class ChildDevelopmentAPIService {
    private let baseURL = "https://kidzzle-api-807625438905.asia-southeast1.run.app/api/v1"
    
    func createAssessment(request: CreateAssessmentRequest, accessToken: String) async throws -> CreateAssessmentResponse {
        
        guard let url = URL(string: "\(baseURL)/assessments/result") else {
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
            
            switch httpResponse.statusCode {
            case 200...299:
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                if data.isEmpty || (String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) == "null") {
                    print("⚠️ Empty or null response with success status code")
                    return CreateAssessmentResponse(code: httpResponse.statusCode, message: "สร้างข้อมูลสำเร็จ แต่ไม่ได้รับข้อมูลตอบกลับ")
                }
                
                do {
                    let decodedResponse = try decoder.decode(CreateAssessmentResponse.self, from: data)
                    return decodedResponse
                } catch {
                    print("⚠️ Decode Failed: \(error)")
                    return CreateAssessmentResponse(code: httpResponse.statusCode, message: "สร้างข้อมูลสำเร็จ แต่ไม่สามารถอ่านข้อมูลตอบกลับได้")
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
    
    func getAgeRanges(assessmentType: String, accessToken: String) async throws -> [AgeRangeData] {
        guard let url = URL(string: "\(baseURL)/assessments/\(assessmentType)/age-range") else {
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
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let decoder = JSONDecoder()
                
                do {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("🔍 Raw JSON for decoding: \(jsonString)")
                    }
                    
                    return try decoder.decode([AgeRangeData].self, from: data)
                    
                } catch {
                    print("❌ Decode Error Details:")
                    print("Error Type: \(type(of: error))")
                    print("Error: \(error)")
                    print("Error Description: \(error.localizedDescription)")
                    
                    throw APIError.serverError(message: "ไม่สามารถอ่านข้อมูลที่ได้รับจากเซิร์ฟเวอร์ได้")
                }
                
            case 404:
                throw APIError.serverError(message: "ไม่พบข้อมูลช่วงอายุ")
                
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
    
    func getAssessmentQuestions(assessmentType: String, ageRangeId: String, accessToken: String) async throws -> [AssessmentQuestionData] {
        
        var urlComponents = URLComponents(string: "\(baseURL)/assessments/\(assessmentType)/question/")
        urlComponents?.queryItems = [URLQueryItem(name: "age_range_id", value: ageRangeId)]
        
        guard let url = urlComponents?.url ?? URL(string: "\(baseURL)/assessments/\(assessmentType)/question/") else {
            throw APIError.invalidURL
        }
        
        print("🌐 กำลังเรียก API URL: \(url.absoluteString)")
        
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
                print("✅ Response Body Preview: \(responseString.prefix(300))...")
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let decoder = JSONDecoder()
                
                do {
                    // ตรวจสอบข้อมูล JSON ก่อนแปลง
                    if let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                        print("📊 จำนวนข้อมูล JSON: \(jsonArray.count) รายการ")
                        
                        // แสดงตัวอย่างข้อมูลแรก
                        if let firstItem = jsonArray.first {
                            print("🔍 ข้อมูล keys ในรายการแรก: \(Array(firstItem.keys))")
                            
                            // ตรวจสอบค่า age_range_id
                            if let ageRangeIdValue = firstItem["age_range_id"] as? String {
                                print("👉 ค่า age_range_id ในข้อมูลแรก: \(ageRangeIdValue)")
                            }
                        }
                    }
                    
                    let result = try decoder.decode([AssessmentQuestionData].self, from: data)
                    print("✅ แปลงข้อมูลสำเร็จ \(result.count) รายการ")
                    return result
                    
                } catch {
                    print("❌ Decode Error: \(error)")
                    throw APIError.serverError(message: "ไม่สามารถอ่านข้อมูลที่ได้รับจากเซิร์ฟเวอร์ได้")
                }
                
            case 404:
                throw APIError.serverError(message: "ไม่พบข้อมูลคำถามประเมิน")
                
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
    
    func getDevelopmentTrainings(
        assessmentType: String,
        assessmentQuestionId: String,
        accessToken: String
    ) async throws -> [DevelopmentTrainingData] {
        // URL construction remains the same
        guard let url = URL(string: "\(baseURL)/assessments/\(assessmentType)/training") else {
            throw APIError.invalidURL
        }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            URLQueryItem(name: "assessment_question_id", value: assessmentQuestionId)
        ]
        
        guard let finalURL = urlComponents?.url else {
            throw APIError.invalidURL
        }
        
        print("🌐 กำลังเรียก API URL: \(finalURL.absoluteString)")
        
        var urlRequest = URLRequest(url: finalURL)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            print("✅ Response Status Code: \(httpResponse.statusCode)")
            
            // Detailed logging of response
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Response Body Preview: \(responseString.prefix(500))...")
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let decoder = JSONDecoder()
                
                do {
                    // Use top-level decoding to get more context
                    let result = try decoder.decode([DevelopmentTrainingData].self, from: data)
                    print("✅ แปลงข้อมูลสำเร็จ \(result.count) รายการ")
                    return result
                    
                } catch {
                    // Detailed error logging
                    print("❌ Decode Error Details:")
                    print("Error Type: \(type(of: error))")
                    print("Error: \(error)")
                    print("Error Description: \(error.localizedDescription)")
                    
                    // Try to print raw JSON for debugging
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("🔍 Raw JSON for debugging:")
                        print(jsonString)
                    }
                    
                    throw APIError.serverError(message: "ไม่สามารถอ่านข้อมูลที่ได้รับจากเซิร์ฟเวอร์ได้")
                }
                
            case 404:
                throw APIError.serverError(message: "ไม่พบข้อมูลการส่งเสริมพัฒนาการ")
                
            case 400...:
                let decoder = JSONDecoder()
                
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
    
    func getAssessmentResults(
        kidId: String,
        ageRangeId: String,
        assessmentTypeId: String,
        accessToken: String
    ) async throws -> [AssessmentResult] {
        guard let url = URL(string: "\(baseURL)/assessments/\(kidId)/\(ageRangeId)/\(assessmentTypeId)/result") else {
            throw APIError.invalidURL
        }
        
        print("🌐 กำลังเรียก API URL: \(url.absoluteString)")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            print("✅ Response Status Code: \(httpResponse.statusCode)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Response Body Preview: \(responseString.prefix(500))...")
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let decoder = JSONDecoder()
                
                do {
                    let result = try decoder.decode([AssessmentResult].self, from: data)
                    print("✅ แปลงข้อมูลสำเร็จ \(result.count) รายการ")
                    return result
                    
                } catch {
                    print("❌ Decode Error Details:")
                    print("Error Type: \(type(of: error))")
                    print("Error: \(error)")
                    print("Error Description: \(error.localizedDescription)")
                    
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("🔍 Raw JSON for debugging:")
                        print(jsonString)
                    }
                    
                    throw APIError.serverError(message: "ไม่สามารถอ่านข้อมูลที่ได้รับจากเซิร์ฟเวอร์ได้")
                }
                
            case 404:
                throw APIError.serverError(message: "ไม่พบข้อมูลการประเมิน")
                
            case 400...:
                let decoder = JSONDecoder()
                
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
