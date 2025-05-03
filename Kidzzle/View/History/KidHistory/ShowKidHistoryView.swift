//
//  ShowKidHistoryView.swift
//  Kidzzle
//
//  Created by aynnipa on 6/4/2568 BE.
//

import SwiftUI
import ScalingHeaderScrollView

struct ShowKidHistoryView: View {
   @ObservedObject var viewModel: KidHistoryViewModel
   @ObservedObject var motherViewModel: MotherPregnantViewModel
   
   @State private var selectedKid: KidHistoryData
   
   @EnvironmentObject var authViewModel: AuthViewModel
   @Environment(\.dismiss) private var dismiss
   
   @State private var progress: CGFloat = 0
   private let minHeight = 100.0
   private let maxHeight = 330.0
   
   @State private var showDeleteConfirmation: Bool = false
   @State private var showEditView: Bool = false
   
   @State private var refreshID = UUID()
   
   init(viewModel: KidHistoryViewModel,
        motherViewModel: MotherPregnantViewModel,
        selectedKid: KidHistoryData,
        authViewModel: AuthViewModel) {
       self.viewModel = viewModel
       self.motherViewModel = motherViewModel
       self._selectedKid = State(initialValue: selectedKid)
   }
   
   var body: some View {
       ZStack {
           ScalingHeaderScrollView {
               largeHeader(progress: progress)
           } content: {
               VStack(spacing: 0) {
                   Color.clear.frame(height: 20)
                   
                   VStack (alignment: .leading, spacing: 24) {
                       HStack (spacing: 16) {
                           // MARK: Edit
                           Button(action: {
                               Task { @MainActor in
                                   viewModel.prepareForUpdate(with: selectedKid)
                                   showEditView = true
                               }
                           }) {
                               HStack (alignment: .center) {
                                   Image(systemName: "pencil")
                                       .font(.system(size: 16))
                                       .foregroundColor(.jetblack)
                                   
                                   Text("แก้ไข")
                                       .font(customFont(type: .medium, textStyle: .body))
                                       .foregroundColor(.jetblack)
                               }
                           }
                           
                           // MARK: Delete
                           Button(action: {
                               showDeleteConfirmation = true
                           }) {
                               HStack (alignment: .center) {
                                   Image(systemName: "xmark.bin.fill")
                                       .font(.system(size: 16))
                                       .foregroundColor(.jetblack)
                                   
                                   Text("ลบ")
                                       .font(customFont(type: .medium, textStyle: .body))
                                       .foregroundColor(.jetblack)
                               }
                           }
                       }
                       .frame(maxWidth: .infinity, alignment: .trailingLastTextBaseline)

                       HistoryLabelText(
                           title: "ชื่อ-นามสกุล",
                           value: selectedKid.kidName ?? "ไม่ระบุ",
                           sfIcon: "person.fill"
                       )
                       
                       HistoryLabelText(
                           title: "วัน/เดือน/ปีเกิด",
                           value: selectedKid.kidBirthday?.normalizeDateFormat() ?? "ไม่ระบุ",
                           sfIcon: "birthday.cake.fill"
                       )
                       
                       HistoryLabelText(
                           title: "เพศ",
                           value: displayGender(selectedKid.kidGender ?? ""),
                           sfIcon: "person.crop.circle.fill"
                       )
                       
                       HistoryLabelText(
                           title: "กรุ๊ปเลือด",
                           value: selectedKid.kidBloodType ?? "ไม่ระบุ",
                           sfIcon: "drop.fill"
                       )
                       
                       HistoryLabelText(
                           title: "ความยาวตัว",
                           value: "\(selectedKid.kidBodyLength ?? "0") ซม.",
                           sfIcon: "figure"
                       )
                       
                       HistoryLabelText(
                           title: "น้ำหนักแรกเกิด",
                           value: "\(selectedKid.kidBirthWeight ?? "0") กก.",
                           sfIcon: "scalemass.fill"
                       )
                       
                       HistoryLabelText(
                           title: "อายุครรภ์ตอนคลอด",
                           value: "\(selectedKid.kidGestationalAge ?? "ไม่ระบุ") สัปดาห์",
                           sfIcon: "clock"
                       )
                       
                       HistoryLabelText(
                           title: "ภาวะขาดออกซิเจน",
                           value: displayOxygen(selectedKid.kidOxygen ?? "ไม่ระบุ"),
                           sfIcon: "lungs.fill"
                       )
                       
                       HistoryLabelText(
                           title: "โรคประจำตัว",
                           value: selectedKid.kidCongenitalDisease ?? "ไม่มี",
                           sfIcon: "stethoscope"
                       )
                   }
                   .padding(.horizontal, 20)
               }
               .padding(.bottom, 40)
           }
           .height(min: minHeight, max: maxHeight)
           .collapseProgress($progress)
           .allowsHeaderGrowth()
           .background(Color.white)
           
           smallHeader
           
           if viewModel.isLoading {
               ProgressView()
                   .progressViewStyle(CircularProgressViewStyle())
           }
       }
       .ignoresSafeArea(.container, edges: [.top, .horizontal])
       .onAppear {
           print("ShowKidHistoryView appeared with: \(selectedKid.kidName ?? "Unknown")")
       }
       .fullScreenCover(isPresented: $showEditView) {
           Task { @MainActor in
               try? await Task.sleep(nanoseconds: 300_000_000)
               
               // ต้องใช้ pregnantId จาก selectedKid
               if let pregnantId = selectedKid.pregnantId {
                   await viewModel.fetchKidHistory(pregnantId: pregnantId)
                   
                   if let updatedKid = viewModel.kidHistoryDataDict[pregnantId]?.first(where: { $0.id == selectedKid.id }) {
                       selectedKid = updatedKid
                       refreshID = UUID()
                   }
               }
           }
       } content: {
           KidHistoryView(
               viewModel: viewModel,
               authViewModel: authViewModel,
               motherViewModel: motherViewModel,
               isLoggedIn: .constant(true)
           )
           .onAppear {
               if let pregnantId = selectedKid.pregnantId {
                   viewModel.pregnantId = pregnantId
                   motherViewModel.selectedPregnantId = pregnantId
               }
           }
       }
       .alert(isPresented: $showDeleteConfirmation) {
           Alert(
               title: Text("ยืนยันการลบ"),
               message: Text("คุณแน่ใจหรือไม่ว่าต้องการลบประวัติของ \(selectedKid.kidName ?? "ลูกน้อย")?"),
               primaryButton: .destructive(Text("ลบ")) {
                   Task {
                       await deleteKidHistory()
                   }
               },
               secondaryButton: .cancel(Text("ยกเลิก"))
           )
       }
   }
   
   // MARK: - Helper Functions
   private func displayGender(_ gender: String) -> String {
       switch gender.lowercased() {
       case "male": return "ชาย"
       case "female": return "หญิง"
       default: return gender
       }
   }
   
   private func displayOxygen(_ value: String) -> String {
       switch value.lowercased() {
       case "yes": return "มี"
       case "no": return "ไม่มี"
       default: return value
       }
   }
   
   // MARK: - API Call Functions
    private func deleteKidHistory() async {
        await viewModel.deleteAndRefreshKidHistory(
            id: selectedKid.id,
            pregnantId: selectedKid.pregnantId
        )
        
        dismiss()
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
                   
                   Text("ประวัติลูกน้อย")
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
                       
                       Spacer()
                       
                       Text("ประวัติลูกน้อย")
                           .font(customFont(type: .bold, textStyle: .headline))
                       
                       Spacer()
                   }
                   
                   VStack (alignment: .leading, spacing: 16) {
                       HStack (alignment: .top) {
                           VStack (alignment: .leading, spacing: 16) {
                               Text("บุตร")
                                   .font(customFont(type: .medium, textStyle: .caption1))
                                   .padding(4)
                                   .padding(.horizontal, 8)
                                   .background(Color.sunYellow)
                                   .cornerRadius(10)
                               
                               Text(selectedKid.kidName ?? "ไม่ทราบชื่อ")
                                   .font(customFont(type: .bold, textStyle: .body))
                                   .lineLimit(1)
                                   .foregroundColor(.jetblack)
                           }
                           
                           Spacer()
                       }
                       
                       HStack {
                           Image(systemName: "birthday.cake.fill")
                               .font(.system(size: 16))
                               .foregroundColor(.jetblack)
                           
                           Text(AgeHelper.formatAge(from: selectedKid.kidBirthday))
                               .font(customFont(type: .regular, textStyle: .footnote))
                       }
                       
                       HStack (spacing: 24) {
                           HStack {
                               Image(systemName: "clock")
                                   .font(.system(size: 16))
                                   .foregroundColor(.jetblack)
                               
                               let gestationalResult = viewModel.evaluateGestationalDeliveryStatus(selectedKid.kidGestationalAge ?? "ไม่ระบุ")
                               Text(gestationalResult.status)
                                   .font(customFont(type: .regular, textStyle: .footnote))
                                   .foregroundColor(gestationalResult.color)
                           }
                           
                           HStack {
                               Image(systemName: "scalemass.fill")
                                   .font(.system(size: 16))
                                   .foregroundColor(.jetblack)
                               
                               let weightResult = viewModel.evaluateBirthWeightStatus(weightString: selectedKid.kidBirthWeight ?? "ไม่ระบุ")
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

