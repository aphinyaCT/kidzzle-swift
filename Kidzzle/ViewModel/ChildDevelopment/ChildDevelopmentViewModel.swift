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
    
    // MARK: - Caching Properties
    
    // เพิ่มตัวแปรสำหรับ caching
    private var lastFetchTimeMap: [String: Date] = [:]
    private let cacheTimeout: TimeInterval = 300 // เพิ่มจาก 30 วินาที เป็น 5 นาที
    
    // MARK: - Loading State Properties
    
    // เพิ่มตัวแปรสำหรับติดตามสถานะการโหลดในแต่ละประเภท
    private var isLoadingAgeRanges = false
    private var isLoadingQuestions = false
    private var isLoadingTrainings = false
    private var isLoadingAssessmentResults = false
    private var isLoadingKidData = false
    
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
    func loadInitialData(forceRefresh: Bool = false) async {
        
        if isLoading {
            print("⚠️ กำลังโหลดข้อมูลอยู่แล้ว จึงข้ามการโหลดซ้ำ")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        await motherViewModel?.fetchMotherPregnant(forceRefresh: forceRefresh)
        
        if let pregnancies = motherViewModel?.motherPregnantDataList {
            if forceRefresh {
                for pregnancy in pregnancies {
                    kidViewModel?.kidHistoryDataDict[pregnancy.id] = nil
                }
            }
            await kidViewModel?.loadAllKidsForPregnancies(pregnancies: pregnancies)
        }
        
        print("✅ โหลดข้อมูลเริ่มต้นเสร็จสมบูรณ์")
        isLoading = false
    }
    
    // MARK: - API Methods: Assessment Creation
    
    @MainActor
    func createAssessment(questionId: String, kidId: String, isPassed: Bool) async -> Bool {
        print("🔍 เริ่มการประเมิน:")
        print("   - Question ID:", questionId)
        print("   - Kid ID:", kidId)
        print("   - Is Passed:", isPassed)
        
        guard let accessToken = authViewModel?.accessToken, !accessToken.isEmpty else {
            errorMessage = "ไม่พบ Access Token"
            print("❌ Missing access token")
            return false
        }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        let request = CreateAssessmentRequest(
            accessToken: accessToken,
            assessment_question_id: questionId,
            is_passed: isPassed,
            kid_id: kidId
        )

        do {
            let response = try await apiService.createAssessment(request: request, accessToken: accessToken)
            
            withAnimation {
                successMessage = response.message
                isLoading = false
            }

            if let selectedAgeRange = selectedAgeRange {
                let cacheKey = "results_\(kidId)_\(selectedAgeRange.ageRangeId)_\(selectedAssessmentType)"
                lastFetchTimeMap[cacheKey] = nil
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
    
    @MainActor
    func fetchAgeRanges(autoLoadQuestions: Bool = true) async {
        
        if isLoadingAgeRanges {
            print("⚠️ กำลังโหลดช่วงอายุอยู่แล้ว จึงข้ามการโหลดซ้ำ")
            return
        }
        
        let cacheKey = "age_ranges_\(selectedAssessmentType)"
        _ = lastFetchTimeMap[cacheKey] == nil ||
        ageRanges.isEmpty ||
        (lastFetchTimeMap[cacheKey] != nil &&
         Date().timeIntervalSince(lastFetchTimeMap[cacheKey]!) > cacheTimeout)
        
        guard let accessToken = authViewModel?.accessToken, !accessToken.isEmpty else {
            errorMessage = "ไม่พบ Access Token"
            print("❌ Missing access token")
            return
        }
        
        isLoading = true
        isLoadingAgeRanges = true
        errorMessage = nil
        
        do {
            ageRanges = try await apiService.getAgeRanges(assessmentType: selectedAssessmentType, accessToken: accessToken)
            
            print("✅ ดึงข้อมูลช่วงอายุสำเร็จ: \(ageRanges.count) รายการ")

            lastFetchTimeMap[cacheKey] = Date()
            
            if autoLoadQuestions {
                if let firstRange = ageRanges.first {
                    selectedAgeRange = firstRange
                    if assessmentQuestions.isEmpty {
                        await fetchAssessmentQuestionsIfNeeded(ageRangeId: firstRange.ageRangeId)
                    }
                }
            }
        } catch let error as APIError {
            errorMessage = error.localizedDescription
            print("❌ API Error: \(error.localizedDescription)")
        } catch {
            errorMessage = "เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ: \(error.localizedDescription)"
            print("❌ Unknown Error: \(error.localizedDescription)")
        }
        
        isLoadingAgeRanges = false
        isLoading = false
    }

    @MainActor
    func fetchAgeRangesIfNeeded() async {
        if isLoadingAgeRanges {
            print("⚠️ กำลังโหลดช่วงอายุอยู่แล้ว จึงข้ามการโหลดซ้ำ")
            return
        }
        
        let cacheKey = "age_ranges_\(selectedAssessmentType)"
        let shouldRefresh = lastFetchTimeMap[cacheKey] == nil ||
        ageRanges.isEmpty ||
        (lastFetchTimeMap[cacheKey] != nil &&
         Date().timeIntervalSince(lastFetchTimeMap[cacheKey]!) > cacheTimeout)
        
        if shouldRefresh {
            print("📡 FETCHING age ranges (type: \(selectedAssessmentType))")
            await fetchAgeRanges()
        } else {
            print("💾 USING CACHED age ranges (last updated: \(lastFetchTimeMap[cacheKey]?.formatted() ?? "unknown"))")
        }
    }

    @MainActor
    func fetchAssessmentQuestions(ageRangeId: String) async {
        errorMessage = nil
        let cacheKey = "questions_\(selectedAssessmentType)_\(ageRangeId)"
        
        isLoading = true
        isLoadingQuestions = true
        
        guard let accessToken = authViewModel?.accessToken, !accessToken.isEmpty else {
            errorMessage = "ไม่พบ Access Token"
            print("❌ Missing access token")
            isLoadingQuestions = false
            isLoading = false
            return
        }
        
        guard let selectedAgeRange = ageRanges.first(where: { $0.ageRangeId == ageRangeId }) else {
            errorMessage = "ไม่พบข้อมูลช่วงอายุที่เลือก"
            print("❌ ไม่พบข้อมูลช่วงอายุสำหรับ ageRangeId: \(ageRangeId)")
            isLoadingQuestions = false
            isLoading = false
            return
        }
        
        let ageRangeName = selectedAgeRange.ageRange
        print("🔍 กำลังค้นหาคำถามสำหรับช่วงอายุ: '\(ageRangeName)' (ID: \(ageRangeId))")
        
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
                
                lastFetchTimeMap[cacheKey] = Date()
            }
            
            if let firstQuestion = assessmentQuestions.first {
                selectedQuestion = firstQuestion
                await fetchDevelopmentTrainingsIfNeeded(questionId: firstQuestion.assessmentQuestionId)
            } else {
                selectedQuestion = nil
                developmentTrainings = []
                errorMessage = "ไม่พบคำถามสำหรับช่วงอายุนี้"
            }
        } catch let error as APIError {
            errorMessage = error.errorDescription
            print("❌ API Error: \(error.errorDescription ?? error.localizedDescription)")
        } catch {
            errorMessage = "เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ"
            print("❌ Unknown Error: \(error.localizedDescription)")
        }
        
        isLoadingQuestions = false
        isLoading = false
    }

    @MainActor
    func fetchAssessmentQuestionsIfNeeded(ageRangeId: String) async {
        if isLoadingQuestions {
            print("⚠️ กำลังโหลดคำถามการประเมินอยู่แล้ว จึงข้ามการโหลดซ้ำ")
            return
        }
        
        let cacheKey = "questions_\(selectedAssessmentType)_\(ageRangeId)"
        let hasQuestionsForAgeRange = assessmentQuestions.contains { $0.ageRangeId == ageRangeId }
        
        let shouldRefresh = lastFetchTimeMap[cacheKey] == nil ||
        !hasQuestionsForAgeRange ||
        (lastFetchTimeMap[cacheKey] != nil &&
         Date().timeIntervalSince(lastFetchTimeMap[cacheKey]!) > cacheTimeout)
        
        if shouldRefresh {
            isLoadingQuestions = true
            
            print("📡 FETCHING assessment questions (ageRangeId: \(ageRangeId))")
            await fetchAssessmentQuestions(ageRangeId: ageRangeId)
        } else {
            print("💾 USING CACHED assessment questions (last updated: \(lastFetchTimeMap[cacheKey]?.formatted() ?? "unknown"))")
        }
    }
    
    @MainActor
    func fetchDevelopmentTrainingsIfNeeded(questionId: String) async {
        if isLoadingTrainings {
            print("⚠️ กำลังโหลดข้อมูลการฝึกทักษะอยู่แล้ว จึงข้ามการโหลดซ้ำ")
            return
        }
        
        let cacheKey = "trainings_\(selectedAssessmentType)_\(questionId)"
        let shouldRefresh = lastFetchTimeMap[cacheKey] == nil ||
        developmentTrainings.isEmpty ||
        (lastFetchTimeMap[cacheKey] != nil &&
         Date().timeIntervalSince(lastFetchTimeMap[cacheKey]!) > cacheTimeout)
        
        if shouldRefresh {
            isLoadingTrainings = true
            
            print("📡 FETCHING development trainings (questionId: \(questionId))")
            await fetchDevelopmentTrainings(questionId: questionId)
        } else {
            print("💾 USING CACHED development trainings (last updated: \(lastFetchTimeMap[cacheKey]?.formatted() ?? "unknown"))")
        }
    }

    @MainActor
    func fetchDevelopmentTrainings(questionId: String) async {

        errorMessage = nil
        let cacheKey = "trainings_\(selectedAssessmentType)_\(questionId)"
        
        guard let accessToken = authViewModel?.accessToken, !accessToken.isEmpty else {
            errorMessage = "ไม่พบ Access Token"
            print("❌ Missing access token")
            isLoadingTrainings = false
            return
        }
        
        guard assessmentQuestions.first(where: { $0.assessmentQuestionId == questionId }) != nil else {
            errorMessage = "ไม่พบข้อมูลคำถามที่เลือก"
            print("❌ ไม่พบข้อมูลคำถาม")
            isLoadingTrainings = false
            return
        }
        
        isLoading = true
        
        do {
            let allTrainings = try await apiService.getDevelopmentTrainings(
                assessmentType: selectedAssessmentType,
                assessmentQuestionId: questionId,
                accessToken: accessToken
            )
            
            print("✅ จำนวนข้อมูลการฝึกทักษะทั้งหมด: \(allTrainings.count) รายการ")
            
            let filteredTrainings = allTrainings.filter { training in
                let typeMatches = training.assessmentTypeId.isEmpty || training.assessmentTypeId == selectedAssessmentType
                let questionMatches = training.assessmentQuestionId.isEmpty || training.assessmentQuestionId == questionId
                
                return typeMatches && questionMatches
            }
            
            print("✅ จำนวนข้อมูลการฝึกทักษะหลังการกรอง: \(filteredTrainings.count) รายการ")
            
            if filteredTrainings.isEmpty {
                print("⚠️ ไม่พบข้อมูลการฝึกทักษะที่ตรงกับเงื่อนไข")
                developmentTrainings = allTrainings
            } else {
                developmentTrainings = filteredTrainings
            }
            
            lastFetchTimeMap[cacheKey] = Date()
        } catch let error as APIError {
            errorMessage = error.localizedDescription
            print("❌ API Error: \(error.localizedDescription)")
            developmentTrainings = []
        } catch {
            errorMessage = "เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ"
            print("❌ Unknown Error: \(error.localizedDescription)")
            developmentTrainings = []
        }
        
        isLoadingTrainings = false
        isLoading = false
    }
    
    @MainActor
    func fetchAssessmentResultsIfNeeded(kidId: String, ageRangeId: String, assessmentTypeId: String) async {
        if isLoadingAssessmentResults {
            print("⚠️ กำลังโหลดผลการประเมินอยู่แล้ว จึงข้ามการโหลดซ้ำ")
            return
        }
        
        let cacheKey = "results_\(kidId)_\(ageRangeId)_\(assessmentTypeId)"

        let shouldRefresh = lastFetchTimeMap[cacheKey] == nil ||
        (lastFetchTimeMap[cacheKey] != nil &&
         Date().timeIntervalSince(lastFetchTimeMap[cacheKey]!) > cacheTimeout)
        
        if shouldRefresh {
            isLoadingAssessmentResults = true
            
            print("📡 FETCHING assessment results (kidId: \(kidId), ageRangeId: \(ageRangeId), assessmentTypeId: \(assessmentTypeId))")
            await fetchAssessmentResults(kidId: kidId, ageRangeId: ageRangeId, assessmentTypeId: assessmentTypeId)
        } else {
            print("💾 USING CACHED assessment results (last updated: \(lastFetchTimeMap[cacheKey]?.formatted() ?? "unknown"))")
        }
    }

    @MainActor
    func fetchAssessmentResults(kidId: String, ageRangeId: String, assessmentTypeId: String) async {

        errorMessage = nil
        let cacheKey = "results_\(kidId)_\(ageRangeId)_\(assessmentTypeId)"

        isLoading = true
        
        guard let accessToken = authViewModel?.accessToken, !accessToken.isEmpty else {
            errorMessage = "ไม่พบ Access Token"
            print("❌ Missing access token")
            isLoadingAssessmentResults = false
            isLoading = false
            return
        }
        
        do {
            let results = try await apiService.getAssessmentResults(
                kidId: kidId,
                ageRangeId: ageRangeId,
                assessmentTypeId: assessmentTypeId,
                accessToken: accessToken
            )

            let filteredResults = results.filter {
                $0.kidId == kidId &&
                $0.ageRangeId == ageRangeId &&
                $0.assessmentTypeId == assessmentTypeId
            }
            
            assessmentResults = filteredResults
            print("✅ ดึงข้อมูลผลการประเมินสำเร็จ: \(assessmentResults.count) รายการ")

            lastFetchTimeMap[cacheKey] = Date()
            
        } catch let error as APIError {
            if case .serverError(let message) = error, message == "ไม่พบข้อมูลการประเมิน" {
                assessmentResults = []
                print("ℹ️ ไม่พบข้อมูลการประเมิน - อาจยังไม่เคยประเมิน")
            } else {
                errorMessage = error.errorDescription
                print("❌ API Error: \(error.errorDescription ?? error.localizedDescription)")
            }
        } catch {
            errorMessage = "เกิดข้อผิดพลาดในการดึงข้อมูล"
            print("❌ Unknown Error: \(error.localizedDescription)")
        }
        
        isLoadingAssessmentResults = false
        isLoading = false
    }
    
    @MainActor
    func fetchKidData() async {
        if isLoadingKidData {
            print("⚠️ กำลังโหลดข้อมูลเด็กอยู่แล้ว จึงข้ามการโหลดซ้ำ")
            return
        }
        
        guard !selectedKidId.isEmpty else {
            errorMessage = "ไม่พบข้อมูลเด็ก"
            return
        }
        
        guard let kidHistoryDataDict = kidViewModel?.kidHistoryDataDict else {
            errorMessage = "ไม่พบข้อมูลประวัติเด็ก"
            return
        }
        
        let cacheKey = "kid_data_\(selectedKidId)"
        let hasKidData = selectedKidData != nil && selectedKidData?.id == selectedKidId
        
        let shouldRefresh = lastFetchTimeMap[cacheKey] == nil ||
        !hasKidData ||
        (lastFetchTimeMap[cacheKey] != nil &&
         Date().timeIntervalSince(lastFetchTimeMap[cacheKey]!) > cacheTimeout)
        
        if shouldRefresh {
            print("📡 FETCHING kid data (kidId: \(selectedKidId))")
        } else {
            print("💾 USING CACHED kid data (last updated: \(lastFetchTimeMap[cacheKey]?.formatted() ?? "unknown"))")
            return
        }
        
        isLoadingKidData = true
        isLoading = true

        for (pregnantId, kids) in kidHistoryDataDict {
            if let kidData = kids.first(where: { $0.id == selectedKidId }) {
                await kidViewModel?.fetchKidHistoryIfNeeded(pregnantId: pregnantId)
                selectedKidData = kidData

                lastFetchTimeMap[cacheKey] = Date()
                isLoadingKidData = false
                isLoading = false
                return
            }
        }
        
        errorMessage = "ไม่พบข้อมูลเด็กที่ระบุ"
        isLoadingKidData = false
        isLoading = false
    }
    
    // MARK: - UI Flow Control
    func handleAgeRangeSelection(_ ageRange: AgeRangeData) {
        selectAgeRange(ageRange)
        
        Task {
            await fetchAssessmentQuestionsIfNeeded(ageRangeId: ageRange.ageRangeId)
            
            await MainActor.run {
                showAgeRangesSheet = false
                showQuestionsSheet = true
            }
        }
    }
    
    func handleQuestionSelection(_ question: AssessmentQuestionData) {
        selectQuestion(question)
        
        Task {
            await fetchDevelopmentTrainingsIfNeeded(questionId: question.assessmentQuestionId)
            
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
            await fetchAgeRangesIfNeeded()
            
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
                Task {
                    await fetchAssessmentResults(
                        kidId: kidId,
                        ageRangeId: selectedAgeRange.ageRangeId,
                        assessmentTypeId: selectedAssessmentType
                    )
                }
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

        let keysToRemove = lastFetchTimeMap.keys.filter { $0.contains(assessmentType) }
        for key in keysToRemove {
            lastFetchTimeMap[key] = nil
        }
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
        lastFetchTimeMap.removeAll()
    }
    
    func clearTrainingData() {
        developmentTrainings = []
    }
    
    func clearCache() {
        lastFetchTimeMap.removeAll()
    }
    
    // MARK: - Assessment Analysis & Utility Methods
    
    func isQuestionAssessed(questionId: String, kidId: String) -> Bool {
        return assessmentResults.contains { $0.assessmentQuestionId == questionId && $0.kidId == kidId }
    }

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
    
    // MARK: - Data Caching & Optimization
    
    @MainActor
    func loadCoreDataIfNeeded() async {
        let cacheKey = "age_ranges_\(selectedAssessmentType)"
        let shouldRefresh = lastFetchTimeMap[cacheKey] == nil ||
        ageRanges.isEmpty ||
        (lastFetchTimeMap[cacheKey] != nil &&
         Date().timeIntervalSince(lastFetchTimeMap[cacheKey]!) > cacheTimeout)
        
        if shouldRefresh {
            print("🔄 Loading core development data...")
        } else {
            print("✅ Using cached development data")
            return
        }
        
        if ageRanges.isEmpty {
            await fetchAgeRanges(autoLoadQuestions: false)
        }
    }
    
    @MainActor
    func refreshAllData() async {
        
        lastFetchTimeMap.removeAll()

        isLoadingAgeRanges = false
        isLoadingQuestions = false
        isLoadingTrainings = false
        isLoadingAssessmentResults = false
        isLoadingKidData = false
        
        await loadCoreDataIfNeeded()
        
        if let selectedAgeRange = selectedAgeRange {
            await fetchAssessmentQuestions(ageRangeId: selectedAgeRange.ageRangeId)
            
            if !selectedKidId.isEmpty {
                await fetchAssessmentResults(
                    kidId: selectedKidId,
                    ageRangeId: selectedAgeRange.ageRangeId,
                    assessmentTypeId: selectedAssessmentType
                )
            }
            
            if let selectedQuestion = selectedQuestion {
                await fetchDevelopmentTrainings(questionId: selectedQuestion.assessmentQuestionId)
            }
        }
    }
}
