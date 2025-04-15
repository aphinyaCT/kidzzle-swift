//
//  MotherPregnantViewModel.swift
//  Kidzzle
//

import SwiftUI
import Combine

class MotherPregnantViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var error: MotherPregnantError?
    @Published var successMessage: String?
    
    // Form Data
    @Published var selectedPregnantId: String = ""
    @Published var motherName: String = ""
    @Published var motherBirthday: Date = Date()
    @Published var pregnantComplications: String = ""
    @Published var pregnantCongenitalDisease: String = ""
    @Published var pregnantDrugHistory: String = ""
    @Published var isUpdateMode = false
    
    // Data Storage
    @Published var motherPregnantDataList: [MotherPregnantData] = [] {
        didSet {
            print("🔔 MotherPregnantData list updated: \(motherPregnantDataList.count) records")
        }
    }
    
    // MARK: - Dependencies
    private let apiService: MotherPregnantAPIService
    private let authViewModel: AuthViewModel
    
    // MARK: - Computed Properties
    var motherPregnantData: MotherPregnantData? {
        return motherPregnantDataList.first
    }
    
    var sortedMotherPregnantData: [MotherPregnantData] {
        motherPregnantDataList.sorted { first, second in
            let firstDate = first.createdAt?.toDate() ?? Date.distantPast
            let secondDate = second.createdAt?.toDate() ?? Date.distantPast
            return firstDate < secondDate
        }
    }
    
    // MARK: - Initialization
    init(apiService: MotherPregnantAPIService = MotherPregnantAPIService(),
         authViewModel: AuthViewModel) {
        self.apiService = apiService
        self.authViewModel = authViewModel
    }
    
    // MARK: - API Methods
    @MainActor
    func createMotherPregnant(
        motherName: String,
        motherBirthday: String,
        pregnantComplications: String,
        pregnantCongenitalDisease: String,
        pregnantDrugHistory: String
    ) async {
        print("🔄 Creating mother pregnant record: \(motherName)")
        
        let accessToken = authViewModel.accessToken
        
        guard !accessToken.isEmpty else {
            error = MotherPregnantError.serverError(message: "ไม่พบ Access Token")
            print("❌ Missing access token")
            return
        }
        
        isLoading = true
        error = nil
        successMessage = nil
        
        guard !motherName.isEmpty, !motherBirthday.isEmpty else {
            error = MotherPregnantError.serverError(message: "กรุณาระบุชื่อและวันเกิดของมารดา")
            print("❌ Missing required data")
            isLoading = false
            return
        }
        
        let request = CreateMotherPregnantRequest(
            accessToken: accessToken,
            mother_birthday: motherBirthday,
            mother_name: motherName,
            pregnant_complications: pregnantComplications.isEmpty ? nil : pregnantComplications,
            pregnant_congenital_disease: pregnantCongenitalDisease.isEmpty ? nil : pregnantCongenitalDisease,
            pregnant_drug_history: pregnantDrugHistory.isEmpty ? nil : pregnantDrugHistory,
            userId: authViewModel.userId
        )
        
        do {
            let response = try await apiService.createMotherPregnant(request: request, accessToken: accessToken)
            
            await MainActor.run {
                self.successMessage = response.message
                self.isLoading = false
            }
            
            await fetchMotherPregnant()
            print("✅ Successfully created mother pregnant record")
            
        } catch let error as MotherPregnantError {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
            print("❌ Error creating mother pregnant: \(error.localizedDescription)")
        } catch {
            await MainActor.run {
                self.error = MotherPregnantError.networkError
                self.isLoading = false
            }
            print("❌ Unknown error: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func fetchMotherPregnant() async {
        
        if isLoading {
            print("⚠️ Already loading, skipping fetch")
            return
        }
        
        print("🔍 Fetching mother pregnant data")
        
        let accessToken = authViewModel.accessToken
        
        guard !accessToken.isEmpty else {
            error = MotherPregnantError.serverError(message: "ไม่พบ Access Token")
            print("❌ Missing access token")
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            let response = try await apiService.getMotherPregnant(accessToken: accessToken)
            
            withAnimation {
                self.motherPregnantDataList = response
                self.isLoading = false
            }
            
            print("✅ Successfully fetched mother pregnant data: \(response.count) records")
        } catch let error as MotherPregnantError {
            withAnimation {
                self.error = error
                self.isLoading = false
                
                if case .serverError(let message) = error, message.contains("ไม่พบข้อมูล") {
                    self.motherPregnantDataList = []
                    print("ℹ️ No mother pregnant data found")
                }
            }
            print("❌ Error fetching mother pregnant data: \(error.localizedDescription)")
        } catch {
            withAnimation {
                self.error = MotherPregnantError.networkError
                self.isLoading = false
            }
            print("❌ Unknown error: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func updateMotherPregnant(
        pregnantId: String,
        motherName: String,
        motherBirthday: String,
        pregnantComplications: String,
        pregnantCongenitalDisease: String,
        pregnantDrugHistory: String
    ) async {
        print("🔄 Updating mother pregnant: \(motherName)")
        
        let accessToken = authViewModel.accessToken
        
        guard !accessToken.isEmpty else {
            error = MotherPregnantError.serverError(message: "ไม่พบ Access Token")
            print("❌ Missing access token")
            return
        }
        
        isLoading = true
        error = nil
        successMessage = nil
        
        guard !motherName.isEmpty, !motherBirthday.isEmpty else {
            withAnimation {
                error = MotherPregnantError.serverError(message: "กรุณาระบุชื่อและวันเกิดของมารดา")
                isLoading = false
            }
            print("❌ Missing required data")
            return
        }
        
        let normalizedBirthDate = motherBirthday.toServerDateFormat()
        
        let request = UpdateMotherPregnantRequest(
            pregnantId: pregnantId,
            motherBirthday: normalizedBirthDate,
            motherName: motherName,
            pregnantComplications: pregnantComplications.isEmpty ? nil : pregnantComplications,
            pregnantCongenitalDisease: pregnantCongenitalDisease.isEmpty ? nil : pregnantCongenitalDisease,
            pregnantDrugHistory: pregnantDrugHistory.isEmpty ? nil : pregnantDrugHistory
        )
        
        do {
            let response = try await apiService.updateKidHistory(
                accessToken: accessToken,
                pregnantId: pregnantId,
                request: request
            )
            
            withAnimation {
                successMessage = response.message
                isLoading = false
            }
            
            await fetchMotherPregnant()
            print("✅ Successfully updated mother pregnant data")
            
        } catch let error as MotherPregnantError {
            withAnimation {
                self.error = error
                self.isLoading = false
            }
            print("❌ Error updating mother pregnant: \(error.localizedDescription)")
        } catch {
            withAnimation {
                self.error = MotherPregnantError.networkError
                self.isLoading = false
            }
            print("❌ Unknown error: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func deleteMotherPregnant(id: String) async {
        print("🗑️ Deleting mother pregnant with ID: \(id)")
        
        let accessToken = authViewModel.accessToken
        
        guard !accessToken.isEmpty else {
            error = MotherPregnantError.serverError(message: "ไม่พบ Access Token")
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
                motherPregnantDataList.removeAll(where: { $0.id == id })
                
                successMessage = response.message
                isLoading = false
                
                objectWillChange.send()
            }
            
            await fetchMotherPregnant()
            print("✅ Successfully deleted mother pregnant data")
            
        } catch let error as MotherPregnantError {
            withAnimation {
                self.error = error
                self.isLoading = false
            }
            print("❌ Error deleting mother pregnant: \(error.localizedDescription)")
        } catch {
            withAnimation {
                self.error = MotherPregnantError.networkError
                self.isLoading = false
            }
            print("❌ Unknown error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Data Preparation
    @MainActor
    func prepareForUpdate(with pregnantData: MotherPregnantData) {
        print("🔄 Preparing update for mother: \(pregnantData.motherName ?? "Unknown")")
        
        var updatedValues = [String: Any]()
        
        updatedValues["selectedPregnantId"] = pregnantData.id
        updatedValues["motherName"] = pregnantData.motherName ?? ""
        
        let birthDate: Date
        
        if let birthDateString = pregnantData.motherBirthday {
            birthDate = birthDateString.parseDate()
            print("🕰️ Original birth date string: \(birthDateString)")
        } else {
            birthDate = Date()
        }
        updatedValues["motherBirthday"] = birthDate
        
        updatedValues["pregnantComplications"] = pregnantData.pregnantComplications ?? ""
        updatedValues["pregnantCongenitalDisease"] = pregnantData.pregnantCongenitalDisease ?? "ไม่มี"
        updatedValues["pregnantDrugHistory"] = pregnantData.pregnantDrugHistory ?? ""
        
        withAnimation {
            self.selectedPregnantId = updatedValues["selectedPregnantId"] as! String
            self.motherName = updatedValues["motherName"] as! String
            
            if let selectedBirthDate = updatedValues["motherBirthday"] as? Date {
                self.motherBirthday = selectedBirthDate
            } else {
                self.motherBirthday = Date()
            }
            
            self.pregnantComplications = updatedValues["pregnantComplications"] as! String
            self.pregnantCongenitalDisease = updatedValues["pregnantCongenitalDisease"] as! String
            self.pregnantDrugHistory = updatedValues["pregnantDrugHistory"] as! String
            self.isUpdateMode = true
        }
        
        print("✅ Update mode prepared successfully")
        print("Selected Pregnant ID: \(selectedPregnantId)")
    }
    
    @MainActor
    func resetMotherPregnantFields() {
        print("🔄 Resetting mother pregnant fields")
        
        withAnimation {
            self.selectedPregnantId = ""
            self.motherName = ""
            self.motherBirthday = Date()
            self.pregnantComplications = ""
            self.pregnantCongenitalDisease = "ไม่มี"
            self.pregnantDrugHistory = ""
            
            self.isUpdateMode = false
            self.successMessage = nil
            self.error = nil
        }
        
        print("✅ Fields reset complete")
    }
    
    // MARK: - Data Loading
    func loadAllData() async {
        print("🔄 Loading all mother pregnant data")
        await fetchMotherPregnant()
    }
}
