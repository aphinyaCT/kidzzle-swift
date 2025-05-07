//
//  ChildDevelopmentMainView.swift
//  Kidzzle
//
//  Created by aynnipa on 15/4/2568 BE.
//

import SwiftUI
import ScalingHeaderScrollView
import SDWebImageSwiftUI

struct ChildDevelopmentMainView: View {

    @State var progress: CGFloat = 0
    
    private let minHeight = 100.0
    private let maxHeight = 200.0

    @ObservedObject var authViewModel: AuthViewModel
    @ObservedObject var motherViewModel: MotherPregnantViewModel
    @ObservedObject var kidViewModel: KidHistoryViewModel

    @StateObject private var developmentViewModel: ChildDevelopmentViewModel

    let manuals = CarouselViewModel.manuals

    init(
        authViewModel: AuthViewModel,
        motherViewModel: MotherPregnantViewModel,
        kidViewModel: KidHistoryViewModel
    ) {
        self.authViewModel = authViewModel
        self.motherViewModel = motherViewModel
        self.kidViewModel = kidViewModel

        _developmentViewModel = StateObject(wrappedValue: ChildDevelopmentViewModel(
            authViewModel: authViewModel,
            kidViewModel: kidViewModel,
            motherViewModel: motherViewModel
        ))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ScalingHeaderScrollView {
                    largeHeader(progress: progress)
                } content: {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 20)

                        VStack(alignment: .leading, spacing: 24) {
                            
                            ManualCarouselView(manuals: manuals)
                                
                            VStack (alignment: .leading, spacing: 10) {
                                Text("การเฝ้าระวังและประเมินพัฒนาการ 5 ด้าน")
                                    .font(customFont(type: .bold, textStyle: .body))
                                    .foregroundColor(.jetblack)

                                Text("เลือกแบบประเมินที่บุคลากรทางการแพทย์แนะนำเท่านั้น")
                                    .font(customFont(type: .regular, textStyle: .callout))
                                    .foregroundColor(.gray)
                            }

                            sortedPregnancyList

                            Text("เบอร์ฉุกเฉินสำหรับแม่และเด็ก")
                                .font(customFont(type: .bold, textStyle: .body))
                                .foregroundColor(.jetblack)

                            EmergencyCallView()
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
                .height(min: minHeight, max: maxHeight)
                .collapseProgress($progress)
                .allowsHeaderGrowth()
                .background(Color.ivorywhite)

                smallHeader
            }
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, alignment: .center)
//            .onAppear {
//                Task {
//                    kidViewModel.kidHistoryDataDict = [:]
//                    
//                    await motherViewModel.fetchMotherPregnant(forceRefresh: true)
//                    
//                    for pregnant in motherViewModel.sortedMotherPregnantData {
//                        await kidViewModel.fetchKidHistoryIfNeeded(pregnantId: pregnant.id)
//                    }
//                }
//            }
            .onAppear {
                Task {
                    await loadInitialData(forceRefresh: false)
                }
            }
            .fullScreenCover(isPresented: $developmentViewModel.showAgeRangesSheet, onDismiss: {
                developmentViewModel.clearQuestionData()
            }) {
                CustomAgeRangesListView(
                    viewModel: developmentViewModel,
                    selectedAssessmentType: developmentViewModel.selectedAssessmentType,
                    onAgeRangeSelected: handleAgeRangeSelection,
                    onDismiss: { developmentViewModel.showAgeRangesSheet = false }
                )
            }
            .fullScreenCover(isPresented: $developmentViewModel.showQuestionsSheet, onDismiss: {
                developmentViewModel.clearTrainingData()
                developmentViewModel.showAgeRangesSheet = true
            }) {
                CustomQuestionsListView(
                    viewModel: developmentViewModel,
                    ageRange: developmentViewModel.selectedAgeRange!,
                    onQuestionSelected: handleQuestionSelection,
                    onDismiss: { developmentViewModel.showQuestionsSheet = false }
                )
            }
            .fullScreenCover(isPresented: $developmentViewModel.showTrainingSheet, onDismiss: {
                developmentViewModel.showTrainingSheet = false
                developmentViewModel.showQuestionsSheet = true
            }) {
                CustomTrainingView(
                    viewModel: developmentViewModel,
                    question: developmentViewModel.selectedQuestion!,
                    onDismiss: { developmentViewModel.showTrainingSheet = false }
                )
            }
        }
    }

    private var smallHeader: some View {
        VStack {
            HStack(spacing: 16) {
                if progress >= 0.99 {
                    WebImage(url: URL(string: authViewModel.userPhoto ?? "https://res.cloudinary.com/dw7lzqrbz/image/upload/v1743320240/KIDZZLE-PROFILE_xtghbp.png"))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())

                    Text("\(authViewModel.isAuthenticated ? (authViewModel.userEmail ?? "คุณ") : "กรุณาเข้าสู่ระบบ")")
                        .font(customFont(type: .bold, textStyle: .subheadline))
                        .foregroundColor(.jetblack)

                    Spacer()

                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.forward")
                            .font(.system(size: 16))
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color.white)
                            .padding(8)
                            .background(Color.jetblack)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 48)
            .transition(
                .opacity
                    .combined(with: .offset(y: -8))
            )
            .animation(.easeInOut(duration: 0.12), value: progress)

            Spacer()
        }
        .ignoresSafeArea(.container, edges: [.top, .horizontal])
    }

    private func largeHeader(progress: CGFloat) -> some View {
        VStack(spacing: 0) {
            ZStack {
                VStack(alignment: .leading, spacing: 10) {
                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.forward")
                            .font(.system(size: 16))
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color.white)
                            .padding(8)
                            .background(Color.jetblack)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)

                    HStack(alignment: .center, spacing: 16) {
                        WebImage(url: URL(string: authViewModel.userPhoto ?? "https://res.cloudinary.com/dw7lzqrbz/image/upload/v1743320240/KIDZZLE-PROFILE_xtghbp.png"))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 64, height: 64)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 10) {
                            Text("สวัสดี, \(authViewModel.isAuthenticated ? (authViewModel.userEmail ?? "คุณ") : "กรุณาเข้าสู่ระบบ")")
                                .font(customFont(type: .bold, textStyle: .headline))
                                .foregroundColor(.jetblack)

                            HStack (spacing: 8) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 16))

                                Text(Date().currentDateString())
                                    .font(customFont(type: .regular, textStyle: .subheadline))
                            }
                            .foregroundColor(.gray)
                        }
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

    private var sortedPregnancyList: some View {
        Group {
            if motherViewModel.motherPregnantDataList.isEmpty {
                EmptyView(message: "ยังไม่มีข้อมูลการตั้งครรภ์")
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(motherViewModel.sortedMotherPregnantData, id: \.id) { pregnant in
                    let kidsForPregnancy = kidViewModel.kidHistoryDataDict[pregnant.id] ?? []

                    Group {
                        if kidsForPregnancy.isEmpty {
                            EmptyView(message: "ยังไม่มีการบันทึกข้อมูลเด็ก\nสามารถเพิ่มข้อมูลได้ที่เมนู 'บันทึกประวัติ'")
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            VStack(alignment: .leading, spacing: 16) {
                                ForEach(kidsForPregnancy, id: \.id) { kid in
                                    AssessmentTypeCard(
                                        kid: kid,
                                        pregnancyIndex: motherViewModel.sortedMotherPregnantData.firstIndex(where: { $0.id == pregnant.id }) ?? 0,
                                        onAssessmentSelected: handleAssessmentTypeSelection,
                                        developmentViewModel: developmentViewModel
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }

//    private func loadInitialData() async {
//        await developmentViewModel.loadInitialData()
//    }
    
    private func loadInitialData(forceRefresh: Bool = false) async {
        await developmentViewModel.loadInitialData(forceRefresh: forceRefresh)
    }

    private func handleAgeRangeSelection(_ ageRange: AgeRangeData) {
        developmentViewModel.handleAgeRangeSelection(ageRange)
    }

    private func handleQuestionSelection(_ question: AssessmentQuestionData) {
        developmentViewModel.handleQuestionSelection(question)
    }

    private func handleAssessmentTypeSelection(kidId: String, assessmentType: String) {
        developmentViewModel.handleAssessmentTypeSelection(kidId: kidId, assessmentType: assessmentType)
    }
}

// MARK: Assesment Type Button
struct AssessmentTypeButton: View {
    let image: String
    let title: String
    let subtitle: String
    let bgColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 12) {
                if let imageUrl = URL(string: image) {
                    WebImage(url: imageUrl)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 48)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(customFont(type: .bold, textStyle: .body))
                        .foregroundColor(.jetblack)
                        .multilineTextAlignment(.leading)

                    Text(subtitle)
                        .font(customFont(type: .regular, textStyle: .footnote))
                        .foregroundColor(.jetblack)
                        .lineLimit(1)
                }
                .padding(.leading, 2)

                Spacer()

                Image(systemName: "arrow.forward")
                    .font(.system(size: 16))
                    .foregroundColor(.jetblack)
                    .padding()
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .cornerRadius(10)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(bgColor)
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: Assessment Type Card
struct AssessmentTypeCard: View {
    let kid: KidHistoryData
    let pregnancyIndex: Int
    let onAssessmentSelected: (String, String) -> Void
    @ObservedObject var developmentViewModel: ChildDevelopmentViewModel
    @State private var navigateToChart = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("ครรภ์ที่ \(pregnancyIndex + 1): \(kid.kidName ?? "ไม่พบชื่อ")")
                .font(customFont(type: .bold, textStyle: .callout))
                .lineLimit(1)

            Text(AgeHelper.formatAge(from: kid.kidBirthday))
                .font(customFont(type: .bold, textStyle: .callout))

            AssessmentTypeButton(
                image: "https://res.cloudinary.com/dw7lzqrbz/image/upload/v1744735943/KIDZZLE-DSPM_sztip9.png",
                title: "ประเมิน DSPM",
                subtitle: "สำหรับเด็กทั่วไป",
                bgColor: Color.softPink
            ) {
                onAssessmentSelected(kid.id, "ASSMTT_1")
            }

            AssessmentTypeButton(
                image: "https://res.cloudinary.com/dw7lzqrbz/image/upload/v1744735956/KIDZZLE-DAIM_p2uz3b.png",
                title: "ประเมิน DAIM",
                subtitle: "สำหรับเด็กกลุ่มเสี่ยง",
                bgColor: Color.greenMint
            ) {
                onAssessmentSelected(kid.id, "ASSMTT_2")
            }
        }
        .padding()
        .background(Color.white.opacity(0.5))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
