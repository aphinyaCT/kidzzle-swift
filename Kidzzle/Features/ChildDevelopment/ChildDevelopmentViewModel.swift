//
//  ChildDevelopmentViewModel.swift
//  Kidzzle
//
//  Created by aynnipa on 10/4/2568 BE.
//

import Foundation
import SwiftUI
import Combine

class ChildDevelopmentViewModel: ObservableObject {
    // MARK: - Dependencies
    
    private let apiService: ChildDevelopmentAPIService
    private weak var authViewModel: AuthViewModel?
    private weak var kidViewModel: KidHistoryViewModel?
    private weak var motherViewModel: MotherPregnantViewModel?
    
    // MARK: - UI State Properties
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    // Sheet Control
    @Published var showAgeRangesSheet = false
    @Published var showQuestionsSheet = false
    @Published var showTrainingSheet = false
    
    // MARK: - Model Data Properties
    
    // ข้อมูลช่วงอายุและคำถามการประเมิน
    @Published var ageRanges: [AgeRangeData] = []
    @Published var assessmentQuestions: [AssessmentQuestionData] = []
    @Published var developmentTrainings: [DevelopmentTrainingData] = []
    @Published var assessmentResults: [AssessmentResult] = []
    
    // MARK: - Selection State Properties
    
    // ตัวแปรสำหรับตัวเลือกที่เลือก
    @Published var selectedAssessmentType: String = "ASSMTT_1"
    @Published var selectedAgeRange: AgeRangeData?
    @Published var selectedQuestion: AssessmentQuestionData?
    
    // ตัวแปรสำหรับ Kid ID
    @Published var selectedKidId: String = ""
    @Published var selectedKidData: KidHistoryData?
    
    // MARK: - Initialization
    
    init(
        apiService: ChildDevelopmentAPIService = ChildDevelopmentAPIService(),
        authViewModel: AuthViewModel?,
        kidViewModel: KidHistoryViewModel?,
        motherViewModel: MotherPregnantViewModel?
    ) {
        self.apiService = apiService
        self.authViewModel = authViewModel
        self.kidViewModel = kidViewModel
        self.motherViewModel = motherViewModel
    }
    
    // MARK: - Initial Data Loading
    
    @MainActor
    func loadInitialData() async {
        isLoading = true
        
        await motherViewModel?.loadAllData()
        if let pregnancies = motherViewModel?.motherPregnantDataList {
            await kidViewModel?.loadAllKidsForPregnancies(pregnancies: pregnancies)
        }
        
        isLoading = false
    }
    
    // MARK: - API Methods: Assessment Creation
    
    @MainActor
    func createAssessment(questionId: String, kidId: String, isPassed: Bool) async -> Bool {
        // Debug input parameters
        print("🔍 เริ่มการประเมิน:")
        print("   - Question ID:", questionId)
        print("   - Kid ID:", kidId)
        print("   - Is Passed:", isPassed)
        
        guard let accessToken = authViewModel?.accessToken, !accessToken.isEmpty else {
            errorMessage = "ไม่พบ Access Token"
            print("❌ Missing access token")
            return false
        }
        
        print("✅ Found access token")
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        let request = CreateAssessmentRequest(
            accessToken: accessToken,
            assessment_question_id: questionId,
            is_passed: isPassed,
            kid_id: kidId
        )
        
        print("📤 ส่งข้อมูลการประเมิน:", request)
        
        do {
            let response = try await apiService.createAssessment(request: request, accessToken: accessToken)
            print("✅ การประเมินสำเร็จ:")
            print("   Response message:", response.message)
            print("   Response code:", response.code)
            
            withAnimation {
                successMessage = response.message
                isLoading = false
            }
            
            return true
        } catch {
            print("❌ การประเมินล้มเหลว:")
            print("   Error:", error.localizedDescription)
            
            withAnimation {
                errorMessage = "เกิดข้อผิดพลาด: \(error.localizedDescription)"
                isLoading = false
            }
            return false
        }
    }
    
    // MARK: - API Methods: Data Fetching
    
    /// ดึงข้อมูลช่วงอายุสำหรับประเภทการประเมินที่กำหนด
    @MainActor
    func fetchAgeRanges() async {
        guard let accessToken = authViewModel?.accessToken, !accessToken.isEmpty else {
            errorMessage = "ไม่พบ Access Token"
            print("❌ Missing access token")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            ageRanges = try await apiService.getAgeRanges(assessmentType: selectedAssessmentType, accessToken: accessToken)
            
            print("✅ ดึงข้อมูลช่วงอายุสำเร็จ: \(ageRanges.count) รายการ")
            
            // เลือกช่วงอายุแรกเป็นค่าเริ่มต้น ถ้ามีข้อมูล
            if let firstRange = ageRanges.first {
                selectedAgeRange = firstRange
                await fetchAssessmentQuestions(ageRangeId: firstRange.ageRangeId)
            }
        } catch let error as APIError {
            errorMessage = error.localizedDescription
            print("❌ API Error: \(error.localizedDescription)")
        } catch {
            errorMessage = "เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ: \(error.localizedDescription)"
            print("❌ Unknown Error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    @MainActor
    func fetchAssessmentQuestions(ageRangeId: String) async {
        guard let accessToken = authViewModel?.accessToken, !accessToken.isEmpty else {
            errorMessage = "ไม่พบ Access Token"
            print("❌ Missing access token")
            return
        }
        
        guard let selectedAgeRange = ageRanges.first(where: { $0.ageRangeId == ageRangeId }) else {
            errorMessage = "ไม่พบข้อมูลช่วงอายุที่เลือก"
            print("❌ ไม่พบข้อมูลช่วงอายุสำหรับ ageRangeId: \(ageRangeId)")
            return
        }
        
        let ageRangeName = selectedAgeRange.ageRange
        print("🔍 กำลังค้นหาคำถามสำหรับช่วงอายุ: '\(ageRangeName)' (ID: \(ageRangeId))")
        
        isLoading = true
        errorMessage = nil
        
        do {
            let allQuestions = try await apiService.getAssessmentQuestions(
                assessmentType: selectedAssessmentType,
                ageRangeId: ageRangeId,
                accessToken: accessToken
            )
            
            print("✅ จำนวนคำถามทั้งหมดจาก API: \(allQuestions.count) รายการ")
            
            let filteredById = allQuestions.filter { $0.ageRangeId == ageRangeId }
            print("✅ จำนวนคำถามที่ตรงกับ ID ช่วงอายุ '\(ageRangeId)': \(filteredById.count) รายการ")
            
            if !filteredById.isEmpty {
                assessmentQuestions = filteredById
                print("🔍 ใช้คำถามที่กรองด้วย ID ช่วงอายุ")
            }
            
            // เลือกคำถามแรกเป็นค่าเริ่มต้น ถ้ามีข้อมูล
            if let firstQuestion = assessmentQuestions.first {
                selectedQuestion = firstQuestion
                await fetchDevelopmentTrainings(questionId: firstQuestion.assessmentQuestionId)
            } else {
                // No questions found for this age range
                selectedQuestion = nil
                developmentTrainings = []
                errorMessage = "ไม่พบคำถามสำหรับช่วงอายุนี้"
            }
        } catch let error as APIError {
            errorMessage = error.localizedDescription
            print("❌ API Error: \(error.localizedDescription)")
        } catch {
            errorMessage = "เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ: \(error.localizedDescription)"
            print("❌ Unknown Error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    @MainActor
    func fetchDevelopmentTrainings(questionId: String) async {
        guard let accessToken = authViewModel?.accessToken, !accessToken.isEmpty else {
            errorMessage = "ไม่พบ Access Token"
            print("❌ Missing access token")
            return
        }
        
        guard let selectedQuestion = assessmentQuestions.first(where: { $0.assessmentQuestionId == questionId }) else {
            errorMessage = "ไม่พบข้อมูลคำถามที่เลือก"
            print("❌ ไม่พบข้อมูลคำถามสำหรับ questionId: \(questionId)")
            return
        }
        
        print("🔍 กำลังค้นหาข้อมูลการฝึกทักษะสำหรับคำถาม: '\(selectedQuestion.questionText)' (ID: \(questionId))")
        print("🔍 ประเภทการประเมิน: '\(selectedAssessmentType)'")
        
        isLoading = true
        errorMessage = nil
        
        do {
            // ดึงข้อมูลการฝึกทักษะทั้งหมด
            let allTrainings = try await apiService.getDevelopmentTrainings(
                assessmentType: selectedAssessmentType,
                assessmentQuestionId: questionId,
                accessToken: accessToken
            )
            
            print("✅ จำนวนข้อมูลการฝึกทักษะทั้งหมดจาก API: \(allTrainings.count) รายการ")
            
            let filteredTrainings = allTrainings.filter { training in
                let typeMatches = training.assessmentTypeId.isEmpty || training.assessmentTypeId == selectedAssessmentType
                let questionMatches = training.assessmentQuestionId.isEmpty || training.assessmentQuestionId == questionId
                
                return typeMatches && questionMatches
            }
            
            print("✅ จำนวนข้อมูลการฝึกทักษะหลังการกรอง: \(filteredTrainings.count) รายการ")
            
            if filteredTrainings.isEmpty {
                print("⚠️ ไม่พบข้อมูลการฝึกทักษะที่ตรงกับเงื่อนไขการกรอง ใช้ข้อมูลทั้งหมดแทน")
                developmentTrainings = allTrainings
            } else {
                developmentTrainings = filteredTrainings
            }
        } catch let error as APIError {
            errorMessage = error.localizedDescription
            print("❌ API Error: \(error.localizedDescription)")
            developmentTrainings = []
        } catch {
            errorMessage = "เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ: \(error.localizedDescription)"
            print("❌ Unknown Error: \(error.localizedDescription)")
            developmentTrainings = []
        }
        
        isLoading = false
    }
    
    @MainActor
    func fetchAssessmentResults(kidId: String, ageRangeId: String, assessmentTypeId: String) async {
        isLoading = true
        errorMessage = nil
        
        guard let accessToken = authViewModel?.accessToken, !accessToken.isEmpty else {
            errorMessage = "ไม่พบ Access Token"
            print("❌ Missing access token")
            return
        }
        
        do {
            assessmentResults = try await apiService.getAssessmentResults(
                kidId: kidId,
                ageRangeId: ageRangeId,
                assessmentTypeId: assessmentTypeId,
                accessToken: accessToken
            )
            print("✅ ดึงข้อมูลผลการประเมินสำเร็จ: \(assessmentResults.count) รายการ")
            isLoading = false
        } catch let error as APIError {
            // ถ้าเป็น 404 ไม่ต้องแสดง error เพราะอาจเป็นกรณีที่ยังไม่เคยประเมิน
            if case .serverError(let message) = error, message == "ไม่พบข้อมูลการประเมิน" {
                assessmentResults = []
                print("ℹ️ ไม่พบข้อมูลการประเมิน - อาจยังไม่เคยประเมิน")
            } else {
                errorMessage = error.errorDescription
                print("❌ API Error: \(error.errorDescription ?? error.localizedDescription)")
            }
            isLoading = false
        } catch {
            errorMessage = "เกิดข้อผิดพลาดในการดึงข้อมูล"
            print("❌ Unknown Error: \(error.localizedDescription)")
            isLoading = false
        }
    }
    
    @MainActor
    func fetchKidData() async {
        guard !selectedKidId.isEmpty else {
            errorMessage = "ไม่พบข้อมูลเด็ก"
            return
        }
        
        guard let kidHistoryDataDict = kidViewModel?.kidHistoryDataDict else {
            errorMessage = "ไม่พบข้อมูลประวัติเด็ก"
            return
        }
        
        // ค้นหาเด็กทั้งหมดใน kidHistoryDataDict
        for (pregnantId, kids) in kidHistoryDataDict {
            if let kidData = kids.first(where: { $0.id == selectedKidId }) {
                // เมื่อพบเด็ก ใช้ pregnantId จากเด็กนั้น
                await kidViewModel?.fetchKidHistory(pregnantId: pregnantId)
                selectedKidData = kidData
                return
            }
        }
        
        errorMessage = "ไม่พบข้อมูลเด็กที่ระบุ"
    }
    
    // MARK: - UI Flow Control
    
    func handleAgeRangeSelection(_ ageRange: AgeRangeData) {
        selectAgeRange(ageRange)
        
        Task {
            await fetchAssessmentQuestions(ageRangeId: ageRange.ageRangeId)
            
            await MainActor.run {
                showAgeRangesSheet = false
                showQuestionsSheet = true
            }
        }
    }

    func handleQuestionSelection(_ question: AssessmentQuestionData) {
        selectQuestion(question)

        Task {
            await fetchDevelopmentTrainings(questionId: question.assessmentQuestionId)
            
            await MainActor.run {
                showQuestionsSheet = false
                showTrainingSheet = true
            }
        }
    }
    
    func handleAssessmentTypeSelection(kidId: String, assessmentType: String) {
        setSelectedKid(kidId: kidId)
        selectAssessmentType(assessmentType)
        
        Task {
            await fetchAgeRanges()
            
            await MainActor.run {
                showAgeRangesSheet = true
            }
        }
    }
    
    func handleAssessment(questionId: String, kidId: String, isPassed: Bool) async -> Bool {
        guard !kidId.isEmpty else {
            errorMessage = "ไม่พบข้อมูลเด็ก"
            return false
        }
        
        let success = await createAssessment(
            questionId: questionId,
            kidId: kidId,
            isPassed: isPassed
        )
        
        if success {
            if let selectedAgeRange = selectedAgeRange {
                await fetchAssessmentResults(
                    kidId: kidId,
                    ageRangeId: selectedAgeRange.ageRangeId,
                    assessmentTypeId: selectedAssessmentType
                )
            }
        }
        
        return success
    }
    
    // MARK: - Dialog/Sheet Management
    
    func dismissAgeRangesSheet() {
        clearQuestionData()
        showAgeRangesSheet = false
    }
    
    func dismissQuestionsSheet() {
        clearTrainingData()
        showAgeRangesSheet = true
        showQuestionsSheet = false
    }
    
    func dismissTrainingSheet() {
        showTrainingSheet = false
        showQuestionsSheet = true
    }
    
    // MARK: - Data Management
    
    func selectAgeRange(_ ageRange: AgeRangeData) {
        selectedAgeRange = ageRange
        selectedQuestion = nil
        developmentTrainings = []
    }
    
    func selectQuestion(_ question: AssessmentQuestionData) {
        selectedQuestion = question
        developmentTrainings = []
    }
    
    func selectAssessmentType(_ assessmentType: String) {
        selectedAssessmentType = assessmentType
        selectedAgeRange = nil
        selectedQuestion = nil
        assessmentQuestions = []
        developmentTrainings = []
    }
    
    func setSelectedKid(kidId: String) {
        selectedKidId = kidId
    }
    
    func resetAssessmentData() {
        withAnimation {
            selectedQuestion = nil
            developmentTrainings = []
            successMessage = nil
            errorMessage = nil
        }
    }
    
    func clearQuestionData() {
        assessmentQuestions = []
        developmentTrainings = []
    }
    
    func clearAllData() {
        selectedKidId = ""
        ageRanges = []
        assessmentQuestions = []
        developmentTrainings = []
    }
    
    func clearTrainingData() {
        developmentTrainings = []
    }
    
    // MARK: - Assessment Analysis & Utility Methods
    
    func isQuestionAssessed(questionId: String, kidId: String) -> Bool {
        return assessmentResults.contains { $0.assessmentQuestionId == questionId && $0.kidId == kidId }
    }
    
    // สำหรับดึงผลการประเมินล่าสุดของคำถาม
    func getLatestAssessmentResult(questionId: String, kidId: String) -> AssessmentResult? {
        let results = assessmentResults.filter {
            $0.assessmentQuestionId == questionId && $0.kidId == kidId
        }.sorted { $0.createdAt > $1.createdAt }
        
        return results.first
    }
    
    func getAssessmentHistory(questionId: String, kidId: String) -> [AssessmentResult] {
        return assessmentResults.filter {
            $0.assessmentQuestionId == questionId && $0.kidId == kidId
        }.sorted { $0.createdAt > $1.createdAt }
    }
    
    func getAssessmentStats(kidId: String, ageRangeId: String, assessmentTypeId: String) -> (passed: Int, total: Int) {
        let relevantResults = assessmentResults.filter {
            $0.kidId == kidId &&
            $0.ageRangeId == ageRangeId &&
            $0.assessmentTypeId == assessmentTypeId
        }
        
        var latestResults: [String: AssessmentResult] = [:]
        for result in relevantResults {
            if let existing = latestResults[result.assessmentQuestionId] {
                if result.createdAt > existing.createdAt {
                    latestResults[result.assessmentQuestionId] = result
                }
            } else {
                latestResults[result.assessmentQuestionId] = result
            }
        }
        
        let passed = latestResults.values.filter { $0.isPassed }.count
        let total = latestResults.count
        
        return (passed, total)
    }
    
    func getAssessmentCount(questionId: String, kidId: String) -> Int {
        return assessmentResults
            .filter {
                $0.assessmentQuestionId == questionId &&
                $0.kidId == kidId
            }
            .count
    }
}
