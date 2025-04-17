//
//  KidHistoryViewModel.swift
//  Kidzzle
//

import SwiftUI
import Combine

class KidHistoryViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var error: KidHistoryError?
    @Published var successMessage: String?
    
    // Form Data
    @Published var kidName: String = ""
    @Published var kidBirthday: Date = Date()
    @Published var kidGender: String = ""
    @Published var kidBirthWeight: String = ""
    @Published var kidBodyLength: String = ""
    @Published var kidBloodType: String = ""
    @Published var kidCongenitalDisease: String = ""
    @Published var kidOxygen: String = ""
    @Published var kidGestationalAge: String = ""
    @Published var pregnantId: String = ""
    @Published var isUpdateMode = false
    @Published var currentKidId: String?

    // Data Storage
    @Published var kidHistoryDataDict: [String: [KidHistoryData]] = [:]
    
    // MARK: - Dependencies
    private let apiService: KidHistoryAPIService
    private let authViewModel: AuthViewModel
    private let motherViewModel: MotherPregnantViewModel
    
    // MARK: - Initialization
    init(apiService: KidHistoryAPIService = KidHistoryAPIService(),
         authViewModel: AuthViewModel,
         motherViewModel: MotherPregnantViewModel) {
        self.apiService = apiService
        self.authViewModel = authViewModel
        self.motherViewModel = motherViewModel
    }

    // MARK: - API Methods
    @MainActor
    func createKidHistory(
        kidName: String,
        birthDate: String,
        gender: String,
        birthWeight: String,
        bodyLength: String,
        bloodType: String,
        congenitalDisease: String,
        oxygen: String,
        gestationalAge: String
    ) async {
        print("🔄 Creating kid history: \(kidName)")
        
        let accessToken = authViewModel.accessToken
        guard !accessToken.isEmpty else {
            error = KidHistoryError.serverError(message: "ไม่พบ Access Token")
            print("❌ Missing access token")
            isLoading = false
            return
        }
        
        let finalPregnantId = !self.pregnantId.isEmpty ? self.pregnantId : motherViewModel.selectedPregnantId
        
        guard !finalPregnantId.isEmpty else {
            error = KidHistoryError.serverError(message: "กรุณาเลือกประวัติการตั้งครรภ์ก่อน")
            print("🚨 pregnantId is EMPTY")
            isLoading = false
            return
        }
        
        isLoading = true
        error = nil
        successMessage = nil
        
        var normalizedGender = gender
        if gender.lowercased() == "ชาย" {
            normalizedGender = "male"
        } else if gender.lowercased() == "หญิง" {
            normalizedGender = "female"
        }
        
        var normalizedOxygen = oxygen
        if oxygen.lowercased() == "มี" {
            normalizedOxygen = "yes"
        } else if oxygen.lowercased() == "ไม่มี" {
            normalizedOxygen = "no"
        }
        
        let request = CreateKidHistoryRequest(
            accessToken: accessToken,
            kid_birth_weight: birthWeight.isEmpty ? nil : birthWeight,
            kid_birthday: birthDate,
            kid_blood_type: bloodType.isEmpty ? nil : bloodType,
            kid_body_length: bodyLength.isEmpty ? nil : bodyLength,
            kid_congenital_disease: congenitalDisease.isEmpty ? nil : congenitalDisease,
            kid_gender: normalizedGender,
            kid_gestational_age: gestationalAge.isEmpty ? nil : gestationalAge,
            kid_name: kidName,
            kid_oxygen: normalizedOxygen,
            pregnantId: finalPregnantId,
            userId: nil
        )
        
        do {
            let response = try await apiService.createKidHistory(request: request, accessToken: accessToken)
            
            await MainActor.run {
                self.successMessage = response.message
                self.isLoading = false
            }
            
            await fetchKidHistory(pregnantId: pregnantId)
            print("✅ Successfully created kid history record")
            
        } catch let error as KidHistoryError {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
            print("❌ Error creating kid history: \(error.localizedDescription)")
        } catch {
            await MainActor.run {
                self.error = KidHistoryError.networkError
                self.isLoading = false
            }
            print("❌ Unknown error: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func updateKidHistory(
        kidId: String,
        kidName: String,
        birthDate: String,
        gender: String,
        birthWeight: String,
        bodyLength: String,
        bloodType: String,
        congenitalDisease: String,
        oxygen: String,
        gestationalAge: String
    ) async {
        print("🔄 Updating kid history: \(kidName)")
        
        let accessToken = authViewModel.accessToken
        
        guard !accessToken.isEmpty else {
            error = KidHistoryError.serverError(message: "ไม่พบ Access Token")
            print("❌ Missing access token")
            return
        }
        
        isLoading = true
        error = nil
        successMessage = nil
        
        guard !kidName.isEmpty, !birthDate.isEmpty else {
            withAnimation {
                error = KidHistoryError.serverError(message: "กรุณาระบุชื่อและวันเกิดของเด็ก")
                isLoading = false
            }
            print("❌ Missing required data")
            return
        }
        
        let normalizedBirthDate = birthDate.toServerDateFormat()
        
        let request = UpdateKidHistoryRequest(
            userId: authViewModel.userId ?? "",
            kidId: kidId,
            kid_birth_weight: birthWeight.isEmpty ? nil : birthWeight,
            kid_birthday: normalizedBirthDate,
            kid_blood_type: bloodType.isEmpty ? nil : bloodType,
            kid_body_length: bodyLength.isEmpty ? nil : bodyLength,
            kid_congenital_disease: congenitalDisease.isEmpty ? nil : congenitalDisease,
            kid_gender: normalizeGender(gender),
            kid_gestational_age: gestationalAge.isEmpty ? nil : gestationalAge,
            kid_name: kidName,
            kid_oxygen: normalizeOxygen(oxygen),
            pregnantId: motherViewModel.selectedPregnantId
        )
        
        do {
            let response = try await apiService.updateKidHistory(
                accessToken: accessToken,
                request: request
            )
            
            withAnimation {
                successMessage = response.message
                isLoading = false
            }
            
            await fetchKidHistory(pregnantId: motherViewModel.selectedPregnantId)
            print("✅ Successfully updated kid history")
            
        } catch let error as KidHistoryError {
            withAnimation {
                self.error = error
                self.isLoading = false
            }
            print("❌ Error updating kid history: \(error.localizedDescription)")
        } catch {
            withAnimation {
                self.error = KidHistoryError.networkError
                self.isLoading = false
            }
            print("❌ Unknown error: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func fetchKidHistory(pregnantId: String) async {
        print("🔍 Fetching kid history for pregnantId: \(pregnantId)")

        let accessToken = authViewModel.accessToken
        guard !accessToken.isEmpty else {
            error = KidHistoryError.serverError(message: "ไม่พบ Access Token")
            print("❌ Missing access token")
            return
        }

        guard !pregnantId.isEmpty else {
            error = KidHistoryError.serverError(message: "ไม่พบ pregnant_id")
            print("❌ No pregnant ID to fetch kid history")
            return
        }

        isLoading = true
        error = nil

        do {
            let response = try await apiService.getKidHistory(
                accessToken: accessToken,
                pregnantId: pregnantId
            )

            withAnimation {
                self.kidHistoryDataDict[pregnantId] = response
                self.isLoading = false
            }

            print("✅ Successfully fetched \(response.count) kid history records")
        } catch let error as KidHistoryError {
            withAnimation {
                self.error = error
                self.isLoading = false
            }
            print("❌ Error fetching kid history: \(error.localizedDescription)")
        } catch {
            withAnimation {
                self.error = KidHistoryError.networkError
                self.isLoading = false
            }
            print("❌ Unknown error: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func deleteKidHistory(id: String) async {
        print("🗑️ Deleting kid history with ID: \(id)")
        
        let accessToken = authViewModel.accessToken
        guard !accessToken.isEmpty else {
            error = KidHistoryError.serverError(message: "ไม่พบ Access Token")
            print("❌ Missing access token")
            return
        }
        
        isLoading = true
        error = nil
        successMessage = nil
        
        do {
            let response = try await apiService.deleteKidHistory(
                id: id,
                accessToken: accessToken
            )
            
            withAnimation {
                for (pregnantId, _) in kidHistoryDataDict {
                    kidHistoryDataDict[pregnantId]?.removeAll(where: { $0.id == id })
                }
                
                successMessage = response.message
                isLoading = false
                
                objectWillChange.send()
            }
            
            print("✅ Successfully deleted kid history")
            
        } catch let error as KidHistoryError {
            withAnimation {
                self.error = error
                self.isLoading = false
            }
            print("❌ Error deleting kid history: \(error.localizedDescription)")
        } catch {
            withAnimation {
                self.error = KidHistoryError.networkError
                self.isLoading = false
            }
            print("❌ Unknown error: \(error.localizedDescription)")
        }
    }
    
    func deleteAndRefreshKidHistory(id: String, pregnantId: String?) async {
        print("🔄 Deleting and refreshing kid history data")
        
        await MainActor.run {
            isLoading = true
            error = nil
        }
     
        await deleteKidHistory(id: id)
        
        await MainActor.run {
            print("🧹 Clearing kid history cache")
            kidHistoryDataDict = [:]
        }
        
        let pregnancies = motherViewModel.motherPregnantDataList
        print("📊 Reloading kid data for \(pregnancies.count) pregnancies")
        await loadAllKidsForPregnancies(pregnancies: pregnancies)
        
        await MainActor.run {
            objectWillChange.send()
            isLoading = false
            print("✅ Kid data refresh complete")
        }
    }
    
    // MARK: - Data Preparation
    @MainActor
    func prepareForUpdate(with kidData: KidHistoryData) {
        print("🔄 Preparing for update with kid: \(kidData.kidName ?? "Unknown")")
        
        var updatedValues = [String: Any]()
        
        self.currentKidId = kidData.id
        updatedValues["currentKidId"] = kidData.id
        
        if let kidPregnantId = kidData.pregnantId {
            updatedValues["pregnantId"] = kidPregnantId
        }
        
        let birthDate: Date
        
        if let birthDateString = kidData.kidBirthday {
            birthDate = birthDateString.parseDate()
        } else {
            birthDate = Date()
        }
        updatedValues["kidBirthday"] = birthDate
        
        updatedValues["kidName"] = kidData.kidName ?? ""
        updatedValues["kidGender"] = convertToThaiGender(kidData.kidGender ?? "")
        updatedValues["kidOxygen"] = convertToThaiOxygen(kidData.kidOxygen ?? "")
        updatedValues["kidBirthWeight"] = kidData.kidBirthWeight ?? ""
        updatedValues["kidBodyLength"] = kidData.kidBodyLength ?? ""
        updatedValues["kidBloodType"] = kidData.kidBloodType ?? ""
        updatedValues["kidCongenitalDisease"] = kidData.kidCongenitalDisease ?? "ไม่มี"
        updatedValues["kidGestationalAge"] = kidData.kidGestationalAge ?? ""
        
        withAnimation {
            if let pregnantId = updatedValues["pregnantId"] as? String {
                self.pregnantId = pregnantId
                motherViewModel.selectedPregnantId = pregnantId
            }
            self.kidName = updatedValues["kidName"] as! String
            self.kidBirthday = updatedValues["kidBirthday"] as! Date
            self.kidGender = updatedValues["kidGender"] as! String
            self.kidOxygen = updatedValues["kidOxygen"] as! String
            self.kidBirthWeight = updatedValues["kidBirthWeight"] as! String
            self.kidBodyLength = updatedValues["kidBodyLength"] as! String
            self.kidBloodType = updatedValues["kidBloodType"] as! String
            self.kidCongenitalDisease = updatedValues["kidCongenitalDisease"] as! String
            self.kidGestationalAge = updatedValues["kidGestationalAge"] as! String
            self.isUpdateMode = true
        }
        
        print("✅ Update mode prepared successfully")
    }
    
    func resetKidHistoryFields() {
        print("🔄 Resetting kid history fields")
        
        withAnimation {
            kidName = ""
            kidBirthday = Date()
            kidGender = ""
            kidBloodType = ""
            kidBodyLength = ""
            kidBirthWeight = ""
            kidCongenitalDisease = "ไม่มี"
            kidOxygen = ""
            kidGestationalAge = ""
            currentKidId = nil
            isUpdateMode = false
            successMessage = nil
            error = nil
        }
        
        print("✅ Fields reset complete")
    }
    
    // MARK: - Data Loading
    func loadAllKidsForPregnancies(pregnancies: [MotherPregnantData]) async {
        for pregnant in pregnancies {
            print("🍼 Loading kid data for mother \(pregnant.id)")
            await fetchKidHistory(pregnantId: pregnant.id)
            print("🚀 Found \(kidHistoryDataDict[pregnant.id]?.count ?? 0) kids for mother \(pregnant.id)")
        }
    }
    
    // MARK: - Helper Functions
    private func selectedPregnantId() -> String? {
        let id = !pregnantId.isEmpty ? pregnantId : motherViewModel.selectedPregnantId
        if id.isEmpty {
            print("❌ No pregnantId found")
            return nil
        }
        return id
    }
    
    private func normalizeGender(_ gender: String) -> String {
        switch gender.lowercased() {
        case "ชาย": return "male"
        case "หญิง": return "female"
        default: return gender
        }
    }
    
    private func normalizeOxygen(_ oxygen: String) -> String {
        switch oxygen.lowercased() {
        case "มี": return "yes"
        case "ไม่มี": return "no"
        default: return oxygen
        }
    }
    
    private func convertToThaiGender(_ gender: String) -> String {
        switch gender.lowercased() {
        case "male": return "ชาย"
        case "female": return "หญิง"
        default: return gender
        }
    }
    
    private func convertToThaiOxygen(_ oxygen: String) -> String {
        switch oxygen.lowercased() {
        case "yes": return "มี"
        case "no": return "ไม่มี"
        default: return oxygen
        }
    }
    
    // MARK: - Status Evaluation Functions
    func evaluateBirthWeightStatus(weightString: String, gestationalAgeString: String) -> String {
        guard let weight = Double(weightString) else { return "น้ำหนักไม่ถูกต้อง" }
        
        let digits = gestationalAgeString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard let gestationalWeeks = Int(digits) else { return "อายุครรภ์ไม่ถูกต้อง" }

        switch gestationalWeeks {
        case ...36:
            if weight < 2.0 {
                return "น้ำหนักน้อยกว่าเกณฑ์"
            } else if weight > 2.5 {
                return "น้ำหนักมากกว่าเกณฑ์"
            } else {
                return "น้ำหนักปกติ"
            }
        case 37...38:
            if weight < 2.5 {
                return "น้ำหนักน้อยกว่าเกณฑ์"
            } else if weight > 3.2 {
                return "น้ำหนักมากกว่าเกณฑ์"
            } else {
                return "น้ำหนักปกติ"
            }
        case 39...40:
            if weight < 2.6 {
                return "น้ำหนักน้อยกว่าเกณฑ์"
            } else if weight > 4.0 {
                return "น้ำหนักมากกว่าเกณฑ์"
            } else {
                return "น้ำหนักปกติ"
            }
        default:
            if weight < 2.8 {
                return "น้ำหนักน้อยกว่าเกณฑ์"
            } else if weight > 4.2 {
                return "น้ำหนักมากกว่าเกณฑ์"
            } else {
                return "น้ำหนักปกติ"
            }
        }
    }
    
    func evaluateGestationalDeliveryStatus(_ gestationalAgeString: String) -> String {
        let digits = gestationalAgeString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard let weeks = Int(digits) else { return "อายุครรภ์ไม่ถูกต้อง" }
        
        if weeks < 37 {
            return "คลอดก่อนกำหนด"
        } else if weeks <= 42 {
            return "คลอดตามกำหนด"
        } else {
            return "คลอดเกินกำหนด"
        }
    }
}
