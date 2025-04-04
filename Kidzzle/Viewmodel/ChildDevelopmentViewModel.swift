//
//  ChildDevelopmentViewModel.swift
//  Kidzzle
//
//  Created by aynnipa on 28/3/2568 BE.
//

import Foundation
import SwiftUI

class ChildDevelopmentViewModel: ObservableObject {
    // Service สำหรับการติดต่อกับ API
    private let apiService = ChildDevelopmentAPIService()
    
    // สถานะ UI
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // ข้อมูลช่วงอายุการประเมิน
    @Published var ageRanges: [AssessmentAgeRangeResponse] = []
    @Published var selectedAgeRange: AssessmentAgeRangeResponse?
    
    // ข้อมูลคำถามการประเมิน
    @Published var assessmentQuestions: [AssessmentQuestionResponse] = []
    @Published var selectedAssessmentType: String = ""
    
    // ข้อมูลคู่มือ
    @Published var manuals: [Manual] = [
        Manual(
            id: 0,
            title: "คู่มือเฝ้าระวังและส่งเสริมพัฒนาการเด็ก",
            subtitle: "Developmental Surveillance and Promotion Manual (DSPM)",
            imageURL: "https://res.cloudinary.com/dw7lzqrbz/image/upload/v1743169535/DSPM_wy6lmh.png",
            detail: "คู่มือที่ใช้ในการคัดกรองและประเมินพัฒนาการ 5 ด้านในเด็กแรกจนถึงอายุ 6 ปี รวมถึงให้คำแนะนำและส่งเสริมให้เด็กมีพัฒนาการสมวัย",
            backgroundColor: .deepBlue
        ),
        Manual(
            id: 1,
            title: "คู่มือประเมินและส่งเสริมพัฒนาการเด็กกลุ่มเสี่ยง",
            subtitle: "Developmental Assessment For Intervention Manual (DAIM)",
            imageURL: "https://res.cloudinary.com/dw7lzqrbz/image/upload/v1743169535/DAIM_dex1zs.png",
            detail: "คู่มือที่ใช้ในการคัดกรองและประเมินพัฒนาการ 5 ด้านในเด็กกลุ่มเสี่ยง รวมถึงให้คำแนะนำและส่งเสริมพัฒนาการเด็กที่ล่าช้า",
            backgroundColor: .assetsPurple
        )
    ]
    
    // ข้อมูลวันที่
    @Published var currentThaiDate: String = ""
    
    // ดึงข้อมูลช่วงอายุสำหรับประเภทการประเมินที่กำหนด
    @MainActor
    func fetchAgeRanges(assessmentType: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // ใช้ assessmentType เป็นส่วนหนึ่งของ endpoint path
            let endpoint = "/assessments/\(assessmentType)/age-range/"
            ageRanges = try await apiService.fetchData(endpoint: endpoint)
            
            print("✅ ดึงข้อมูลช่วงอายุสำเร็จ: \(ageRanges.count) รายการ")
            
            // เลือกช่วงอายุแรกเป็นค่าเริ่มต้น ถ้ามีข้อมูล
            if let firstRange = ageRanges.first {
                selectedAgeRange = firstRange
                await fetchAssessmentQuestions(assessmentType: assessmentType, ageRangeId: firstRange.id)
            }
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    // ดึงข้อมูลคำถามการประเมิน
    @MainActor
    func fetchAssessmentQuestions(assessmentType: String, ageRangeId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let endpoint = "/assessments/\(assessmentType)/questions/\(ageRangeId)"
            assessmentQuestions = try await apiService.fetchData(endpoint: endpoint)
            print("✅ ดึงข้อมูลคำถามการประเมินสำเร็จ: \(assessmentQuestions.count) รายการ")
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    // เลือกช่วงอายุ
    func selectAgeRange(_ ageRange: AssessmentAgeRangeResponse) {
        selectedAgeRange = ageRange
        
        // ดึงข้อมูลคำถามอัตโนมัติเมื่อเลือกช่วงอายุ
        Task {
            await fetchAssessmentQuestions(assessmentType: selectedAssessmentType, ageRangeId: ageRange.id)
        }
    }
    
    // เลือกประเภทการประเมิน
    func selectAssessmentType(_ assessmentType: String) {
        selectedAssessmentType = assessmentType
        selectedAgeRange = nil
        assessmentQuestions = []
        
        // ดึงข้อมูลช่วงอายุอัตโนมัติเมื่อเลือกประเภทการประเมิน
        Task {
            await fetchAgeRanges(assessmentType: assessmentType)
        }
    }
    
    // แปลงเดือนเป็นปีสำหรับการแสดงผล
    func convertMonthsToYearsDisplay(min: String, max: String) -> String {
        let minVal = Int(min) ?? 0
        let maxVal = Int(max) ?? 0
        
        let minDisplay = minVal < 12 ? "\(minVal) เดือน" : String(format: "%.1f ปี", Double(minVal) / 12.0)
        let maxDisplay = maxVal < 12 ? "\(maxVal) เดือน" : String(format: "%.1f ปี", Double(maxVal) / 12.0)
        
        return "\(minDisplay) - \(maxDisplay)"
    }
    
    // จัดการกับข้อผิดพลาด
    private func handleError(_ error: Error) {
        if let apiError = error as? APIError {
            switch apiError {
            case .invalidURL:
                errorMessage = "URL ไม่ถูกต้อง"
            case .invalidResponse:
                errorMessage = "การตอบกลับจากเซิร์ฟเวอร์ไม่ถูกต้อง"
            case .httpError(let statusCode):
                errorMessage = "เกิดข้อผิดพลาดจากเซิร์ฟเวอร์ (รหัส: \(statusCode))"
            case .serverError(let message):
                errorMessage = message
            case .decodingError(let decodingError):
                errorMessage = "เกิดข้อผิดพลาดในการแปลงข้อมูล: \(decodingError.localizedDescription)"
            case .unknownError:
                errorMessage = "เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ"
            }
        } else {
            errorMessage = "เกิดข้อผิดพลาด: \(error.localizedDescription)"
        }
        
        print("❌ API Error: \(errorMessage ?? "Unknown error")")
    }
    
    init() {
        updateCurrentDate()
    }
    
    private func updateCurrentDate() {
        currentThaiDate = getThaiFormattedDate()
    }
    
    func getThaiFormattedDate(from date: Date = Date()) -> String {
        let thaiDateFormatter = DateFormatter()
        thaiDateFormatter.locale = Locale(identifier: "th_TH")
        thaiDateFormatter.dateFormat = "EEEE d MMMM yyyy"
        return thaiDateFormatter.string(from: date)
    }
}
