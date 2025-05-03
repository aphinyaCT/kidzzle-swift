//
//  KidHistoryView.swift
//  Kidzzle
//
//  Created by aynnipa on 6/4/2568 BE.
//

import SwiftUI
import ScalingHeaderScrollView

struct KidHistoryView: View {
    @ObservedObject var viewModel: KidHistoryViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var motherViewModel: MotherPregnantViewModel
    @Binding var isLoggedIn: Bool
    
    @State private var progress: CGFloat = 0
    
    private let minHeight = 100.0
    private let maxHeight = 200.0
    
    @Environment(\.dismiss) private var dismiss
    
    let kidBloodTypeOptions = [
        "A+", "A−",
        "B+", "B−",
        "AB+", "AB−",
        "O+", "O−"
    ]
    let kidOxygenOptions = ["มี", "ไม่มี"]
    let kidGenderOptions = ["ชาย", "หญิง"]
    
    init(viewModel: KidHistoryViewModel, authViewModel: AuthViewModel, motherViewModel: MotherPregnantViewModel, isLoggedIn: Binding<Bool> = .constant(true)) {
        self.viewModel = viewModel
        self.motherViewModel = motherViewModel
        _isLoggedIn = isLoggedIn
    }
    
    var body: some View {
        ZStack {
            ScalingHeaderScrollView {
                largeHeader(progress: progress)
            } content: {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 20)
                    
                    VStack (alignment: .leading, spacing: 24) {
                        CustomHistoryTextField(
                            title: "ชื่อ-นามสกุล",
                            hint: "ชื่อ-นามสกุล",
                            sfIcon: "person.fill",
                            value: $viewModel.kidName
                        )
                        
                        CustomWheelDatePickerView(
                            selectedDate: $viewModel.kidBirthday,
                            title: "วัน/เดือน/ปีเกิด"
                        )
                        
                        HStack {
                            CustomDropdownPickerView(
                                selectedOption: $viewModel.kidGender,
                                options: kidGenderOptions,
                                title: "เพศ",
                                sfIcon: "person.crop.circle.fill"
                            )
                            
                            Spacer()
                            
                            CustomDropdownPickerView(
                                selectedOption: $viewModel.kidBloodType,
                                options: kidBloodTypeOptions,
                                title: "กรุ๊ปเลือด",
                                sfIcon: "drop.fill"
                            )
                        }
                        
                        HStack {
                            CustomHistoryTextField(
                                title: "ความยาวตัว",
                                hint: "ความยาว",
                                sfIcon: "figure",
                                value: $viewModel.kidBodyLength,
                                isHeight: true,
                                measurementUnit: "ซม."
                            )
                            
                            Spacer()
                            
                            CustomHistoryTextField(
                                title: "น้ำหนักแรกเกิด",
                                hint: "น้ำหนัก",
                                sfIcon: "scalemass.fill",
                                value: $viewModel.kidBirthWeight,
                                isWeight: true,
                                measurementUnit: "กรัม"
                            )
                        }
                        
                        HStack {
                            CustomHistoryTextField(
                                title: "อายุครรภ์ตอนคลอด",
                                hint: "อายุ",
                                sfIcon: "clock",
                                value: $viewModel.kidGestationalAge,
                                isGestationalAge: true,
                                measurementUnit: "สัปดาห์"
                            )
                            
                            Spacer()
                            
                            CustomDropdownPickerView(
                                selectedOption: $viewModel.kidOxygen,
                                options: kidOxygenOptions,
                                title: "ภาวะขาดออกซิเจน",
                                sfIcon: "lungs.fill"
                            )
                        }
                        
                        CustomHistoryTextField(
                            title: "โรคประจำตัว (ถ้ามี ระบุชื่อโรคสั้น ๆ)",
                            hint: "โรคประจำตัว",
                            sfIcon: "stethoscope",
                            value: $viewModel.kidCongenitalDisease
                        )
                        
                        Spacer()
                        
                        Button(action: {
                            Task {
                                if viewModel.isUpdateMode {
                                    await updateKidHistory()
                                } else {
                                    await createKidHistory()
                                }
                            }
                        }) {
                            Text(viewModel.isUpdateMode ? "แก้ไข" : "บันทึก")
                                .font(customFont(type: .bold, textStyle: .callout))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(isFormValid ? Color.jetblack : Color.gray.opacity(0.5))
                                .cornerRadius(10)
                        }
                        .disabled(!isFormValid || viewModel.isLoading)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
            .height(min: minHeight, max: maxHeight)
            .collapseProgress($progress)
            .allowsHeaderGrowth()
            .background(Color.ivorywhite)
            
            smallHeader
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .ignoresSafeArea(.container, edges: [.top, .horizontal])
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if !viewModel.isUpdateMode || viewModel.currentKidId == nil {
                    viewModel.resetKidHistoryFields()
                }
            }
        }
        .onChange(of: authViewModel.isAuthenticated) { _, newValue in
            if !newValue {
                isLoggedIn = false
            }
        }
        .toast(isShowing: $authViewModel.showLoginSuccessToast, toastCase: .loginSuccess, duration: 1.5)
        .toast(isShowing: $authViewModel.showTokenExpiredToast, toastCase: .tokenExpired, duration: 1.5)
    }
    
    private var isFormValid: Bool {
        
        let hasPregnantId = !motherViewModel.selectedPregnantId.isEmpty
        let allFieldsValid = !viewModel.kidName.isEmpty &&
        !viewModel.kidBodyLength.isEmpty &&
        !viewModel.kidBirthWeight.isEmpty &&
        !viewModel.kidCongenitalDisease.isEmpty &&
        !viewModel.kidGender.isEmpty &&
        !viewModel.kidGestationalAge.isEmpty &&
        !viewModel.kidOxygen.isEmpty &&
        !viewModel.kidBloodType.isEmpty &&
        hasPregnantId
        
        return allFieldsValid && !viewModel.isLoading
    }
    
    // MARK: - Create and Update Functions
    private func createKidHistory() async {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        
        let formattedBirthday = dateFormatter.string(from: viewModel.kidBirthday)
        
        await viewModel.createKidHistory(
            kidName: viewModel.kidName,
            birthDate: formattedBirthday,
            gender: viewModel.kidGender,
            birthWeight: viewModel.kidBirthWeight,
            bodyLength: viewModel.kidBodyLength,
            bloodType: viewModel.kidBloodType,
            congenitalDisease: viewModel.kidCongenitalDisease,
            oxygen: viewModel.kidOxygen,
            gestationalAge: viewModel.kidGestationalAge
        )
        
        if viewModel.successMessage != nil {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 100_000_000)
                dismiss()
            }
        }
    }
    
    private func updateKidHistory() async {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        
        let formattedBirthday = dateFormatter.string(from: viewModel.kidBirthday)
        
        if let currentKidId = viewModel.currentKidId {
            await viewModel.updateKidHistory(
                kidId: currentKidId,
                kidName: viewModel.kidName,
                birthDate: formattedBirthday,
                gender: viewModel.kidGender,
                birthWeight: viewModel.kidBirthWeight,
                bodyLength: viewModel.kidBodyLength,
                bloodType: viewModel.kidBloodType,
                congenitalDisease: viewModel.kidCongenitalDisease,
                oxygen: viewModel.kidOxygen,
                gestationalAge: viewModel.kidGestationalAge
            )
            
            if viewModel.successMessage != nil {
                try? await Task.sleep(nanoseconds: 300_000_000)
                
                await viewModel.fetchKidHistory(pregnantId: viewModel.pregnantId)
                
                await MainActor.run {
                    dismiss()
                }
            }
        } else {
            viewModel.error = APIError.serverError(message: "ไม่พบรหัสข้อมูลลูกน้อยที่ต้องการแก้ไข")
        }
    }
    
    private var smallHeader: some View {
        VStack {
            HStack (spacing: 16) {
                if progress >= 0.99 {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 16))
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color.jetblack)
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(10)
                    })
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    Text(!viewModel.isUpdateMode ? "เพิ่มประวัติลูกน้อย" : "แก้ไขประวัติลูกน้อย")
                        .font(customFont(type: .bold, textStyle: .subheadline))
                    
                    Spacer()
                }
            }
            .transition(
                .opacity
                    .combined(with: .offset(y: -8))
            )
            .animation(.easeInOut(duration: 0.12), value: progress)
            .padding(.horizontal, 20)
            .padding(.top, 48)
            
            Spacer()
        }
        .ignoresSafeArea(.container, edges: [.top, .horizontal])
    }
    
    private func largeHeader(progress: CGFloat) -> some View {
        VStack(spacing: 0) {
            ZStack {
                VStack(alignment: .leading, spacing: 24) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 16))
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color.jetblack)
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(10)
                    })
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    Text(!viewModel.isUpdateMode ? "เพิ่มประวัติลูกน้อย" : "แก้ไขประวัติลูกน้อย")
                        .font(customFont(type: .bold, textStyle: .title2))
                    
                    if !motherViewModel.selectedPregnantId.isEmpty {
                        Text("อ้างอิง: \(motherViewModel.selectedPregnantId)")
                            .font(customFont(type: .regular, textStyle: .body))
                            .foregroundColor(.gray)
                    }
                    
                }
                .foregroundColor(Color.jetblack)
                .padding(.horizontal, 20)
                .padding(.top, 64)
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(progress >= 1.0 ? 0 : 1)
                .offset(y: progress >= 1.0 ? -5 : 0)
                .animation(.easeOut(duration: 0.15), value: progress)
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .background(Color.ivorywhite)
    }
}

#Preview {
    KidHistoryView(
        viewModel: KidHistoryViewModel(
            authViewModel: AuthViewModel(),
            motherViewModel: MotherPregnantViewModel(authViewModel: AuthViewModel())
        ),
        authViewModel: AuthViewModel(),
        motherViewModel: MotherPregnantViewModel(authViewModel: AuthViewModel()),
        isLoggedIn: .constant(true)
    )
    .environmentObject(AuthViewModel())
}
