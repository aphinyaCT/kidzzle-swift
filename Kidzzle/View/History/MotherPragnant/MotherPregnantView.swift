//
//  MotherPregnantView.swift
//  Kidzzle
//
//  Created on 8/4/2568 BE.
//

import SwiftUI
import ScalingHeaderScrollView

struct MotherPregnantView: View {
    
    @ObservedObject var viewModel: MotherPregnantViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var isLoggedIn: Bool
    
    @State private var progress: CGFloat = 0
    
    private let minHeight = 100.0
    private let maxHeight = 180.0
    
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: MotherPregnantViewModel,
         authViewModel: AuthViewModel,
         isLoggedIn: Binding<Bool> = .constant(true)) {
        self.viewModel = viewModel
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
                            title: "ชื่อ-นามสกุล (มารดา)",
                            hint: "ชื่อ-นามสกุล",
                            sfIcon: "person.fill",
                            value: $viewModel.motherName,
                        )
                        
                        CustomWheelDatePickerView(
                            selectedDate: $viewModel.motherBirthday,
                            title: "วัน/เดือน/ปีเกิด (มารดา)"
                        )
                        
                        CustomHistoryTextField(
                            title: "โรคประจำตัว (ถ้ามี ระบุชื่อโรคสั้น ๆ)",
                            hint: "โรคประจำตัว",
                            sfIcon: "stethoscope",
                            value: $viewModel.pregnantCongenitalDisease,
                        )
                        
                        CustomDropdownPickerView(
                            selectedOption: $viewModel.pregnantComplications,
                            options: ["ไม่มี", "ความดันโลหิตสูง", "เบาหวาน", "ครรภ์เป็นพิษ", "โลหิตจาง"],
                            title: "ภาวะแทรกซ้อนระหว่างตั้งครรภ์",
                            sfIcon: "exclamationmark.triangle.fill"
                        )
                        
                        CustomDropdownPickerView(
                            selectedOption: $viewModel.pregnantDrugHistory,
                            options: ["ไม่มี", "สูบบุหรี่", "ดื่มแอลกอฮอล์", "ทั้งสูบบุหรี่และดื่มแอลกอฮอล์"],
                            title: "การสูบบุหรี่หรือดื่มแอลกอฮอล์ขณะตั้งครรภ์",
                            sfIcon: "pills.fill"
                        )
                        
                        Spacer()
                        
                        Button(action: {
                            Task {
                                if viewModel.isUpdateMode {
                                    await updateMotherPregnant()
                                } else {
                                    await createMotherPregnant()
                                }
                            }
                        }) {
                            Text(viewModel.isUpdateMode ? "แก้ไข" : "บันทึก")
                                .font(customFont(type: .bold, textStyle: .callout))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.jetblack)
                                .cornerRadius(10)
                        }
                        .disabled({
                            return viewModel.isLoading || viewModel.motherName.isEmpty
                        }())

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
                if !viewModel.isUpdateMode || viewModel.selectedPregnantId.isEmpty {
                    viewModel.resetMotherPregnantFields()
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
    
    // MARK: - Create and Update Functions

    private func createMotherPregnant() async {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        
        let formattedBirthday = dateFormatter.string(from: viewModel.motherBirthday)
        
        await viewModel.createMotherPregnant(
            motherName: viewModel.motherName,
            motherBirthday: formattedBirthday,
            pregnantComplications: viewModel.pregnantComplications,
            pregnantCongenitalDisease: viewModel.pregnantCongenitalDisease,
            pregnantDrugHistory: viewModel.pregnantDrugHistory
        )
        
        if viewModel.successMessage != nil {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 100_000_000)
                dismiss()
            }
        }
    }

    private func updateMotherPregnant() async {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.calendar = Calendar(identifier: .gregorian)

        let formattedBirthday = dateFormatter.string(from: viewModel.motherBirthday)
        
        await viewModel.updateMotherPregnant(
            pregnantId: viewModel.selectedPregnantId,
            motherName: viewModel.motherName,
            motherBirthday: formattedBirthday,
            pregnantComplications: viewModel.pregnantComplications,
            pregnantCongenitalDisease: viewModel.pregnantCongenitalDisease,
            pregnantDrugHistory: viewModel.pregnantDrugHistory
        )
        
        if viewModel.successMessage != nil {
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 วินาที
            
            await viewModel.fetchMotherPregnant()
            
            await MainActor.run {
                dismiss()
            }
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
                            .foregroundColor(Color.white)
                            .padding(8)
                            .background(Color.jetblack)
                            .cornerRadius(10)
                    })
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    Text(!viewModel.isUpdateMode ? "เพิ่มประวัติการตั้งครรภ์" : "แก้ไขประวัติการตั้งครรภ์")
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
                            .foregroundColor(Color.white)
                            .padding(8)
                            .background(Color.jetblack)
                            .cornerRadius(10)
                    })
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    Text(!viewModel.isUpdateMode ? "เพิ่มประวัติการตั้งครรภ์" : "แก้ไขประวัติการตั้งครรภ์")
                        .font(customFont(type: .bold, textStyle: .title2))
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
    MotherPregnantView(viewModel: MotherPregnantViewModel(authViewModel: AuthViewModel()), authViewModel: AuthViewModel(), isLoggedIn: .constant(true))
        .environmentObject(AuthViewModel())
}
