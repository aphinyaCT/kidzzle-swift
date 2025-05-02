//
//  ShowMotherPregnantView.swift
//  Kidzzle
//
//  Created on 8/4/2568 BE.
//

import SwiftUI
import ScalingHeaderScrollView

struct ShowMotherPregnantView: View {
    @ObservedObject var motherViewModel: MotherPregnantViewModel
    
    @StateObject private var kidViewModel: KidHistoryViewModel
    
    @State private var showAddKidView: Bool = false
    @State private var selectedKid: KidHistoryData?
    
    @State private var selectedPregnant: MotherPregnantData
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var progress: CGFloat = 0
    private let minHeight = 100.0
    private let maxHeight = 330.0
    
    @State private var showDeleteConfirmation: Bool = false
    @State private var showEditView: Bool = false
    @State private var showDetailView: Bool = false
    @State private var showChildDevelopmentView:Bool = false
    
    @State private var refreshID = UUID()
    
    // อัปเดต initializer
    init(motherViewModel: MotherPregnantViewModel, selectedPregnant: MotherPregnantData, authViewModel: AuthViewModel, kidViewModel: KidHistoryViewModel) {
        self.motherViewModel = motherViewModel
        self._selectedPregnant = State(initialValue: selectedPregnant)
        self._kidViewModel = StateObject(wrappedValue: kidViewModel)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ScalingHeaderScrollView {
                    largeHeader(progress: progress)
                } content: {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 20)
                        
                        VStack (alignment: .leading, spacing: 24) {
                            HStack {
                                Text("ประวัติลูกน้อย")
                                    .font(customFont(type: .bold, textStyle: .body))
                                
                                Spacer()
                                
                                
                                
                                Button(action: {
                                    // Set both selectedPregnantId and pregnantId
                                    let selectedPregnantId = selectedPregnant.id
                                    
                                    motherViewModel.selectedPregnantId = selectedPregnantId
                                    kidViewModel.pregnantId = selectedPregnantId
                                    
                                    // Reset fields
                                    kidViewModel.resetKidHistoryFields()
                                    
                                    showAddKidView = true
                                }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.jetblack)
                                        .padding()
                                        .frame(width: 32, height: 32)
                                        .background(Color.jetblack.opacity(0.1))
                                        .cornerRadius(10)
                                }
                            }
                            
                            if let kidsForPregnancy = kidViewModel.kidHistoryDataDict[selectedPregnant.id], !kidsForPregnancy.isEmpty {
                                VStack(spacing: 16) {
                                    ForEach(kidsForPregnancy, id: \.id) { kid in
                                        KidCardView(kid: kid, viewModel: kidViewModel)
                                            .onTapGesture {
                                                print("กำลังเลือกข้อมูลเด็ก: \(kid.kidName ?? "Unknown"), ID: \(kid.id)")
                                                selectedKid = kid
                                            }
                                    }
                                }
                            } else {
                                Text("กดปุ่ม '+' เพื่อสร้างประวัติลูกน้อย")
                                    .font(customFont(type: .regular, textStyle: .body))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 20)
                            }
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
                
                if motherViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .ignoresSafeArea(.container, edges: [.top, .horizontal])
            .onAppear {
                print("ShowMotherPregnantView appeared with: \(selectedPregnant.motherName ?? "Unknown")")
                
                kidViewModel.pregnantId = selectedPregnant.id
                Task {
                    // ใช้ fetchKidHistoryIfNeeded แทน fetchKidHistory เพื่อลดการเรียก API ซ้ำ
                    await kidViewModel.fetchKidHistoryIfNeeded(pregnantId: kidViewModel.pregnantId)
                }
            }
            .fullScreenCover(isPresented: $showDetailView) {
                MotherDetailView(selectedPregnant: selectedPregnant)
            }
            .fullScreenCover(isPresented: $showEditView) {
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    
                    // ทำรีเฟรชเฉพาะเมื่อจำเป็น
                    await motherViewModel.fetchMotherPregnant(forceRefresh: true)
                    
                    if let updatedPregnant = motherViewModel.motherPregnantDataList.first(where: { $0.id == selectedPregnant.id }) {
                        selectedPregnant = updatedPregnant
                        
                        refreshID = UUID()
                    }
                }
            } content: {
                MotherPregnantView(
                    viewModel: motherViewModel,
                    authViewModel: authViewModel,
                    isLoggedIn: .constant(true)
                )
            }
            .fullScreenCover(isPresented: $showAddKidView) {
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    // ใช้ fetchKidHistoryIfNeeded แทน fetchKidHistory
                    await kidViewModel.fetchKidHistoryIfNeeded(pregnantId: kidViewModel.pregnantId)
                }
            } content: {
                KidHistoryView(
                    viewModel: kidViewModel,
                    authViewModel: authViewModel,
                    motherViewModel: motherViewModel,
                    isLoggedIn: .constant(true)
                )
            }
            .fullScreenCover(item: $selectedKid) { kid in
                ShowKidHistoryView(
                    viewModel: kidViewModel,
                    motherViewModel: motherViewModel,
                    selectedKid: kid,
                    authViewModel: authViewModel
                )
                .onDisappear {
                    Task { @MainActor in
                        await kidViewModel.fetchKidHistoryIfNeeded(pregnantId: kidViewModel.pregnantId)
                        kidViewModel.resetKidHistoryFields()
                    }
                }
            }
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("ยืนยันการลบ"),
                    message: Text("คุณแน่ใจหรือไม่ว่าต้องการลบประวัติการตั้งครรภ์ของ \(selectedPregnant.motherName ?? "มารดา")?"),
                    primaryButton: .destructive(Text("ลบ")) {
                        Task {
                            await deleteMotherPregnant()
                        }
                    },
                    secondaryButton: .cancel(Text("ยกเลิก"))
                )
            }
        }
    }
    
    // MARK: - API Call Functions
    private func deleteMotherPregnant() async {
        await motherViewModel.deleteMotherPregnant(id: selectedPregnant.id)
        
        await MainActor.run {
            dismiss()
        }
    }
    
    // MARK: - View Components
    private var smallHeader: some View {
        VStack {
            HStack(spacing: 16) {
                if progress >= 0.99 {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 24))
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color.jetblack)
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    
                    Text("บันทึกประวัติมารดาและบุตร")
                        .font(customFont(type: .bold, textStyle: .headline))
                        .foregroundColor(Color.jetblack)
                        .transition(
                            .opacity
                                .combined(with: .offset(y: -8))
                        )
                        .animation(.easeInOut(duration: 0.12), value: progress)
                }
                
                Spacer()
            }
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
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.backward")
                                .font(.system(size: 24))
                                .frame(width: 24, height: 24)
                                .foregroundColor(Color.jetblack)
                                .padding(8)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        
                        Text("บันทึกประวัติมารดาและบุตร")
                            .font(customFont(type: .bold, textStyle: .headline))
                            .padding(.leading, 10)
                        
                        Spacer()
                    }
                    
                    VStack (alignment: .leading, spacing: 16) {
                        HStack (alignment: .top) {
                            
                            VStack (alignment: .leading, spacing: 24) {
                                
                                HStack (alignment: .top, spacing: 10) {
                                    
                                    Text("มารดา")
                                        .font(customFont(type: .medium, textStyle: .caption1))
                                        .padding(4)
                                        .padding(.horizontal, 8)
                                        .background(Color.sunYellow)
                                        .cornerRadius(10)
                                    
                                    Spacer()
                                    
                                    // MARK: Details
                                    Button(action: {
                                        Task { @MainActor in
                                            motherViewModel.prepareForUpdate(with: selectedPregnant)
                                            showDetailView = true
                                        }
                                    }) {
                                        Image(systemName: "eye")
                                            .font(.system(size: 16))
                                            .foregroundColor(.jetblack)
                                            .padding()
                                            .frame(width: 40, height: 40)
                                            .background(Color.sunYellow)
                                            .cornerRadius(10)
                                    }
                                    
                                    // MARK: Edit
                                    Button(action: {
                                        Task { @MainActor in
                                            motherViewModel.prepareForUpdate(with: selectedPregnant)
                                            showEditView = true
                                        }
                                    }) {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 16))
                                            .foregroundColor(.jetblack)
                                            .padding()
                                            .frame(width: 40, height: 40)
                                            .background(Color.sunYellow)
                                            .cornerRadius(10)
                                    }
                                    
                                    // MARK: Delete
                                    Button(action: {
                                        showDeleteConfirmation = true
                                    }) {
                                        Image(systemName: "xmark.bin.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.jetblack)
                                            .padding()
                                            .frame(width: 40, height: 40)
                                            .background(Color.sunYellow)
                                            .cornerRadius(10)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .trailingLastTextBaseline)
                                
                                Text(selectedPregnant.motherName ?? "ไม่ทราบชื่อ")
                                    .font(customFont(type: .bold, textStyle: .body))
                                    .lineLimit(1)
                                    .foregroundColor(.jetblack)
                            }
                            
                        }
                        
                        HStack {
                            Image(systemName: "birthday.cake.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.jetblack)
                            
                            Text(AgeHelper.formatAge(from: selectedPregnant.motherBirthday))
                                .font(customFont(type: .regular, textStyle: .footnote))
                        }
                        
                        HStack {
                            Image(systemName: "person.fill.checkmark")
                                .font(.system(size: 16))
                                .foregroundColor(.jetblack)
                            
                            Text("อ้างอิง: \(selectedPregnant.id.prefix(12))")
                                .font(customFont(type: .regular, textStyle: .footnote))
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.sunYellow, lineWidth: 1)
                    )
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

// MARK: - Mother Detail View
struct MotherDetailView: View {
    let selectedPregnant: MotherPregnantData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.ivorywhite
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.jetblack)
                        .frame(width: 36, height: 36)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .padding(.top, 40)
                
                // Title
                Text("ประวัติการตั้งครรภ์มารดา")
                    .font(customFont(type: .bold, textStyle: .title2))
                
                VStack (alignment: .leading, spacing: 16) {
                    HistoryLabelText(
                        title: "ชื่อ-นามสกุล (มารดา)",
                        value: selectedPregnant.motherName ?? "ไม่ระบุ",
                        sfIcon: "person.fill"
                    )
                    
                    HistoryLabelText(
                        title: "วัน/เดือน/ปีเกิด (มารดา)",
                        value: selectedPregnant.motherBirthday?.normalizeDateFormat() ?? "ไม่ระบุ",
                        sfIcon: "birthday.cake.fill"
                    )
                    
                    HistoryLabelText(
                        title: "โรคประจำตัว",
                        value: selectedPregnant.pregnantCongenitalDisease ?? "ไม่มี",
                        sfIcon: "stethoscope"
                    )
                    
                    HistoryLabelText(
                        title: "ภาวะแทรกซ้อนระหว่างตั้งครรภ์",
                        value: selectedPregnant.pregnantComplications ?? "ไม่มี",
                        sfIcon: "exclamationmark.triangle.fill"
                    )
                    
                    HistoryLabelText(
                        title: "การสูบบุหรี่หรือดื่มแอลกอฮอล์ขณะตั้งครรภ์",
                        value: selectedPregnant.pregnantDrugHistory ?? "ไม่มี",
                        sfIcon: "pills.fill"
                    )
                    
                    HistoryLabelText(
                        title: "อ้างอิง",
                        value: String(selectedPregnant.id.prefix(12)),
                        sfIcon: "person.fill.checkmark"
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct KidCardView: View {
    let kid: KidHistoryData
    let viewModel: KidHistoryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("บุตร")
                        .font(customFont(type: .medium, textStyle: .caption1))
                        .padding(4)
                        .padding(.horizontal, 8)
                        .background(Color.sunYellow)
                        .cornerRadius(10)
                    
                    Text(kid.kidName ?? "ไม่ทราบชื่อ")
                        .font(customFont(type: .bold, textStyle: .body))
                        .lineLimit(1)
                        .foregroundColor(.jetblack)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.forward")
                    .font(.system(size: 24))
                    .foregroundColor(.jetblack)
                    .padding()
                    .frame(width: 40, height: 40)
                    .background(Color.sunYellow)
                    .cornerRadius(10)
            }
            
            HStack {
                Image(systemName: "birthday.cake.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.jetblack)
                
                Text(AgeHelper.formatAge(from: kid.kidBirthday))
                    .font(customFont(type: .regular, textStyle: .footnote))
            }
            
            HStack (spacing: 24) {
                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 16))
                        .foregroundColor(.jetblack)
                    
                    let gestationalResult = viewModel.evaluateGestationalDeliveryStatus(kid.kidGestationalAge ?? "ไม่ระบุ")
                    Text(gestationalResult.status)
                        .font(customFont(type: .regular, textStyle: .footnote))
                        .foregroundColor(gestationalResult.color)
                }
                
                HStack {
                    Image(systemName: "scalemass.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.jetblack)
                    
                    let weightResult = viewModel.evaluateBirthWeightStatus(weightString: kid.kidBirthWeight ?? "ไม่ระบุ")
                    Text(weightResult.status)
                        .font(customFont(type: .regular, textStyle: .footnote))
                        .foregroundColor(weightResult.color)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.sunYellow, lineWidth: 1)
        )
    }
}
