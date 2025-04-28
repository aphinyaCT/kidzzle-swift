//
//  HistoryView.swift
//  Kidzzle
//
//  Created by aynnipa on 5/4/2568 BE.
//

import SwiftUI
import ScalingHeaderScrollView

struct HistoryView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @StateObject private var kidViewModel: KidHistoryViewModel
    @StateObject private var motherViewModel: MotherPregnantViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var progress: CGFloat = 0
    @State private var showAddKidView: Bool = false
    @State private var showAddMotherView: Bool = false
    @State private var selectedPregnant: MotherPregnantData?

    private let minHeight = 100.0
    private let maxHeight = 230.0

    init() {
        let authVM = AuthViewModel()
        _kidViewModel = StateObject(wrappedValue: KidHistoryViewModel(
            authViewModel: authVM,
            motherViewModel: MotherPregnantViewModel(authViewModel: authVM)
        ))
        _motherViewModel = StateObject(wrappedValue: MotherPregnantViewModel(authViewModel: authVM))
    }
    
    var body: some View {
        GeometryReader { geometry in
            let columns = adaptiveColumns(for: geometry.size.width)
            
            ZStack {
                ScalingHeaderScrollView {
                    largeHeader(progress: progress)
                } content: {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 20)
                        
                        VStack(alignment: .leading, spacing: 24) {
                            HStack {
                                Text("ประวัติมารดา")
                                    .font(customFont(type: .bold, textStyle: .body))
                                
                                Spacer()
                                
                                Button(action: {
                                    withAnimation {
                                        motherViewModel.resetMotherPregnantFields()
                                        showAddMotherView = true
                                    }
                                }, label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.jetblack)
                                        .padding()
                                        .frame(width: 32, height: 32)
                                        .background(Color.jetblack.opacity(0.1))
                                        .cornerRadius(10)
                                })
                            }
                            
                            if motherViewModel.motherPregnantDataList.isEmpty {
                                EmptyView(message: "กดปุ่ม '+' เพื่อสร้างประวัติการตั้งครรภ์มารดา")
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else {
                                ScrollView {
                                    LazyVGrid(
                                        columns: columns,
                                        spacing: 20
                                    ) {
                                        ForEach(motherViewModel.sortedMotherPregnantData, id: \.id) { pregnant in
                                            MotherPregnantCardView(pregnant: pregnant, viewModel: motherViewModel)
                                                .onTapGesture {
                                                    print("กำลังเลือกข้อมูลการตั้งครรภ์: \(pregnant.motherName ?? "Unknown"), ID: \(pregnant.id)")
                                                    selectedPregnant = pregnant
                                                    
                                                    let pregnantId = pregnant.id
                                                    Task {
                                                        await kidViewModel.fetchKidHistory(pregnantId: pregnantId)
                                                    }
                                                }
                                        }
                                    }
                                }
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
                
                if kidViewModel.isLoading || motherViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(.container, edges: [.top, .horizontal])
            .onAppear {
                Task {
                    await motherViewModel.fetchMotherPregnant()
                }
            }
            .fullScreenCover(isPresented: $showAddMotherView) {
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    await motherViewModel.fetchMotherPregnant()
                }
            } content: {
                MotherPregnantView(
                    viewModel: motherViewModel,
                    authViewModel: authViewModel,
                    isLoggedIn: .constant(true)
                )
            }
            .fullScreenCover(item: $selectedPregnant) { pregnant in
                ShowMotherPregnantView(
                    motherViewModel: motherViewModel,
                    selectedPregnant: pregnant,
                    authViewModel: authViewModel,
                    kidViewModel: kidViewModel
                )
                .onDisappear {
                    Task {
                        await motherViewModel.fetchMotherPregnant()
                        motherViewModel.resetMotherPregnantFields()
                    }
                }
            }
            .toast(isShowing: $authViewModel.showLoginSuccessToast, toastCase: .loginSuccess, duration: 1.5)
        }
    }
    
    func adaptiveColumns(for width: CGFloat) -> [GridItem] {
        let columnCount = width > 700 ? 2 :
                          width > 500 ? 2 : 1
        
        return Array(repeating:
            GridItem(.flexible(), spacing: 20),
            count: columnCount
        )
    }
    
    private var smallHeader: some View {
        VStack {
            HStack(spacing: 16) {
                if progress >= 0.99 {
                    Image(systemName: "bookmark")
                        .font(.system(size: 16))
                        .frame(width: 16, height: 16)
                        .foregroundColor(Color.white)
                        .padding(8)
                        .background(Color.sunYellow)
                        .cornerRadius(10)
                    
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
            .padding(.leading, 20)
            .padding(.top, 48)
            
            Spacer()
        }
        .ignoresSafeArea(.container, edges: [.top, .horizontal])
    }
    
    private func largeHeader(progress: CGFloat) -> some View {
        VStack(spacing: 0) {
            ZStack {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 24))
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color.white)
                        .padding(8)
                        .background(Color.sunYellow)
                        .cornerRadius(10)
                    
                    Text("บันทึกประวัติ")
                        .font(customFont(type: .bold, textStyle: .title2))
                    
                    Text("ขั้นตอนการใช้งาน:\n1. ประวัติมารดา: กดปุ่ม '+' เพื่อสร้างประวัติมารดา > กรอกข้อมูลและบันทึก\n2. ประวัติบุตร: กดเลือกประวัติมารดา > กดปุ่ม '+' เพื่อสร้างประวัติลูกน้อย")
                        .font(customFont(type: .regular, textStyle: .caption1))
                        .multilineTextAlignment(.leading)
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

// MARK: Mother Pregnant Card
struct MotherPregnantCardView: View {
    let pregnant: MotherPregnantData
    let viewModel: MotherPregnantViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("มารดาและลูกน้อย")
                        .font(customFont(type: .medium, textStyle: .caption1))
                        .padding(4)
                        .padding(.horizontal, 8)
                        .background(Color.sunYellow)
                        .cornerRadius(10)
                    
                    Text(pregnant.motherName ?? "ไม่ทราบชื่อ")
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
            
            Spacer()
            
            HStack {
                Image(systemName: "birthday.cake.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.jetblack)
                
                Text(AgeHelper.formatAge(from: pregnant.motherBirthday))
                    .font(customFont(type: .regular, textStyle: .footnote))
                    .lineLimit(2)
            }
            
            HStack {
                HStack {
                    Image(systemName: "person.fill.checkmark")
                        .font(.system(size: 16))
                        .foregroundColor(.jetblack)
                    
                    Text("\(pregnant.id.prefix(12))")
                        .font(customFont(type: .regular, textStyle: .footnote))
                }
                
                Spacer()
                
                HStack {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 16))
                        .foregroundColor(.jetblack)
                    
                    Text("สร้างเมื่อ: \(pregnant.createdAt?.normalizeDateFormat() ?? "ไม่พบวันที่สร้าง")")
                        .font(customFont(type: .regular, textStyle: .footnote))
                }
                
                Spacer()
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

#Preview {
    HistoryView()
        .environmentObject(AuthViewModel())
}
