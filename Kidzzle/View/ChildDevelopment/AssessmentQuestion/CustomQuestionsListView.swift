//
//  CustomQuestionsListView.swift
//  Kidzzle
//
//  Created by aynnipa on 14/4/2568 BE.
//

import SwiftUI
import ScalingHeaderScrollView

struct CustomQuestionsListView: View {
    @ObservedObject var viewModel: ChildDevelopmentViewModel
    let ageRange: AgeRangeData
    let onQuestionSelected: (AssessmentQuestionData) -> Void
    let onDismiss: () -> Void
    
    @State private var isLoading = true
    @State private var showAssessmentToast = false
    @State private var selectedTab: QuestionTab = .questions
    
    @State var progress: CGFloat = 0
    
    private let minHeight = 100.0
    private let maxHeight = 200.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ScalingHeaderScrollView {
                    largeHeader(progress: progress)
                } content: {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 20)
                        
                        VStack(alignment: .leading, spacing: 24) {

                            TabSelectorView(selectedTab: $selectedTab)
                            
                            if selectedTab != .summary && ageRange.assessmentVdoUrl != nil && !(ageRange.assessmentVdoUrl?.isEmpty ?? true) {
                                Button(action: {
                                    if let videoUrl = ageRange.assessmentVdoUrl,
                                       let url = URL(string: videoUrl),
                                       UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "video.bubble")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                        
                                        Text("วิดีโอสาธิตการประเมิน")
                                            .foregroundColor(.white)
                                            .font(customFont(type: .bold, textStyle: .callout))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(Color.coralRed)
                                    .cornerRadius(10)
                                }
                            }
                            
                            if selectedTab == .questions {
                                if isLoading {
                                    VStack {
                                        ProgressView()
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                } else {
                                    if viewModel.assessmentQuestions.isEmpty {
                                        EmptyView(message: "ไม่พบข้อมูลการประเมิน")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    } else {
                                        LazyVStack(spacing: 16) {
                                            ForEach(viewModel.assessmentQuestions, id: \.assessmentQuestionId) { question in
                                                QuestionExpandingCard(
                                                    viewModel: viewModel,
                                                    question: question,
                                                    onQuestionSelected: onQuestionSelected,
                                                    onAssessmentComplete: { success in
                                                        withAnimation {
                                                            showAssessmentToast = true
                                                        }
                                                    }
                                                )
                                            }
                                        }
                                    }
                                }
                            } else {
                                AssessmentChartView(
                                    viewModel: viewModel,
                                    kidId: viewModel.selectedKidId,
                                    ageRangeId: ageRange.ageRangeId,
                                    assessmentTypeId: viewModel.selectedAssessmentType
                                )
                            }
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
//                isLoading = true
//                Task {
//                    await viewModel.fetchAssessmentQuestionsIfNeeded(ageRangeId: ageRange.ageRangeId)
//                    isLoading = false
//                }
//            }
            .onAppear {
                isLoading = true
                Task {
                    await viewModel.fetchKidData()
                    
                    if let selectedAgeRange = viewModel.selectedAgeRange {
                        await viewModel.fetchAssessmentResultsIfNeeded(
                            kidId: viewModel.selectedKidId,
                            ageRangeId: selectedAgeRange.ageRangeId,
                            assessmentTypeId: viewModel.selectedAssessmentType
                        )
                    }
                    
                    await viewModel.fetchAssessmentQuestionsIfNeeded(ageRangeId: ageRange.ageRangeId)
                    isLoading = false
                }
            }
            .toast(isShowing: $showAssessmentToast, toastCase: .assessmentSuccess, duration: 0.8)
        }
    }
    
    private var smallHeader: some View {
        VStack {
            HStack(spacing: 16) {
                if progress >= 0.99 {
                    Button(action: {
                        onDismiss()
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

                    let displayText = if ageRange.ageRange == "แรกเกิด - 1 เดือน" || ageRange.ageRange == "แรกเกิด" {
                        ageRange.ageRange
                    } else {
                        StringHelper.removeParenthesesContent(from: ageRange.ageRange) + " เดือน"
                    }

                    Text("ช่วงอายุ\(displayText) (\(viewModel.selectedAssessmentType == "ASSMTT_1" ? "DSPM" : "DAIM"))")
                        .font(customFont(type: .bold, textStyle: .headline))
                }
                
                Spacer()
            }
            .padding(.leading, 20)
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
                        onDismiss()
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
                    
                    Text("ประเมินพัฒนาการ\(viewModel.selectedAssessmentType == "ASSMTT_1" ? "เด็กทั่วไป" : "เด็กกลุ่มเสี่ยง") 5 ด้าน (\(viewModel.selectedAssessmentType == "ASSMTT_1" ? "DSPM" : "DAIM"))")
                        .font(customFont(type: .bold, textStyle: .title2))
                    
                    let displayText = if ageRange.ageRange == "แรกเกิด - 1 เดือน" || ageRange.ageRange == "แรกเกิด" {
                        ageRange.ageRange
                    } else {
                        StringHelper.removeParenthesesContent(from: ageRange.ageRange) + " เดือน"
                    }
                    
                    Text("ช่วงอายุ \(displayText)")
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

// MARK: Question Expanding Card
struct QuestionExpandingCard: View {
    @ObservedObject var viewModel: ChildDevelopmentViewModel
    let question: AssessmentQuestionData
    let onQuestionSelected: (AssessmentQuestionData) -> Void
    @State private var isExpanded = false
    let onAssessmentComplete: (Bool) -> Void
    
    private var isAssessed: Bool {
        viewModel.isQuestionAssessed(questionId: question.assessmentQuestionId, kidId: viewModel.selectedKidId)
    }

    private var latestResult: AssessmentResult? {
        viewModel.getLatestAssessmentResult(questionId: question.assessmentQuestionId, kidId: viewModel.selectedKidId)
    }

    private var isPassed: Bool {
        latestResult?.isPassed ?? false
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AssessmentStatusHelper.getStatusBackgroundColor(
                                isAssessed: isAssessed,
                                isPassed: isPassed
                            ))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: AssessmentStatusHelper.getStatusIcon(
                            isAssessed: isAssessed,
                            isPassed: isPassed
                        ))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AssessmentStatusHelper.getStatusIconColor(
                                isAssessed: isAssessed,
                                isPassed: isPassed
                            ))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("#\(question.assessmentNo)")
                            .font(customFont(type: .regular, textStyle: .caption1))
                            .foregroundColor(.gray)
                        
                        Text("\(DevelopmentTypeHelper.getFullName(question.developmentType))")
                            .font(customFont(type: .bold, textStyle: .headline))
                            .foregroundColor(.jetblack)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 10)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    Divider()
                    
                    Text("ทักษะ: \(question.questionText)")
                        .font(customFont(type: .medium, textStyle: .body))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 4)
                    
                    HStack {
                        Image(systemName: "birthday.cake")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                        
                        if let kidBirthdayString = viewModel.selectedKidData?.kidBirthday,
                           let kidBirthday = kidBirthdayString.toDate(),
                           let latest = latestResult {
                            let ageAtAssessment = AgeHelper.formatAgeAtAssessment(from: kidBirthday, to: latest.createdAt)
                            Text("อายุตอนประเมิน: \(ageAtAssessment)")
                                .font(customFont(type: .regular, textStyle: .caption1))
                                .foregroundColor(.primary)
                        } else {
                            Text("ยังไม่มีการประเมิน")
                                .font(customFont(type: .regular, textStyle: .caption1))
                                .foregroundColor(.primary)
                        }
                    }
                    
                    if let latest = latestResult {
                        HStack {
                            Image(systemName: "calendar")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                            
                            Text("ประเมินล่าสุด: \(latest.createdAt.currentDateString())")
                                .font(customFont(type: .regular, textStyle: .caption1))
                                .foregroundColor(.primary)
                        }
                    } else {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.gray)
                            Text("ยังไม่มีการประเมิน")
                                .font(customFont(type: .regular, textStyle: .caption1))
                                .foregroundColor(.primary)
                        }
                    }
                    
                    if let latest = latestResult {
                        withAnimation {
                            HStack {
                                let assessmentCount = viewModel.getAssessmentCount(
                                    questionId: question.assessmentQuestionId,
                                    kidId: viewModel.selectedKidId
                                )
                                
                                VStack (alignment: .leading, spacing: 8) {
                                    Text("ประเมินครั้งที่ #\(assessmentCount)")
                                        .font(customFont(type: .regular, textStyle: .caption1))
                                        .foregroundColor(.secondary)
                                    
                                    Text(latest.createdAt.currentDateString())
                                        .font(customFont(type: .regular, textStyle: .caption1))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: latest.isPassed ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(latest.isPassed ? .green : .red)
                                Text(latest.isPassed ? "ผ่านการประเมิน" : "ไม่ผ่านการประเมิน")
                                    .font(customFont(type: .medium, textStyle: .callout))
                                    .foregroundColor(latest.isPassed ? .green : .red)
                                    .padding(.leading, 4)
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                        }
                    } else {
                        Text("ยังไม่มีข้อมูลการประเมิน")
                            .font(customFont(type: .regular, textStyle: .body))
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 16) {
                        // MARK: Passed
                        Button(action: {
                            Task {
                                let success = await viewModel.handleAssessment(
                                    questionId: question.assessmentQuestionId,
                                    kidId: viewModel.selectedKidId,
                                    isPassed: true
                                )
                                if success {
                                    onAssessmentComplete(true)
                                    isExpanded = false
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("ผ่าน")
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(latestResult == nil ? Color.green.opacity(0.2) : Color.green)
                            .foregroundColor(latestResult == nil ? Color.green : .white)
                            .cornerRadius(10)
                        }
                        .disabled(viewModel.isLoading)
                        
                        // MARK: Failed
                        Button(action: {
                            Task {
                                let success = await viewModel.handleAssessment(
                                    questionId: question.assessmentQuestionId,
                                    kidId: viewModel.selectedKidId,
                                    isPassed: false
                                )
                                if success {
                                    onAssessmentComplete(true)
                                    isExpanded = false
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                Text("ไม่ผ่าน")
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(latestResult == nil ? Color.red.opacity(0.2) : Color.red)
                            .foregroundColor(latestResult == nil ? Color.red : .white)
                            .cornerRadius(10)
                        }
                        .disabled(viewModel.isLoading)
                    }
                    .font(customFont(type: .medium, textStyle: .subheadline))
                    
                    // MARK: Manual
                    Button(action: {
                        onQuestionSelected(question)
                    }) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.white)
                            
                            Text("คู่มือการประเมินและการฝึกทักษะ")
                                .foregroundColor(.white)
                                .font(customFont(type: .medium, textStyle: .subheadline))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.jetblack)
                        .cornerRadius(10)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 12)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .shadow(color: isExpanded ? Color.black.opacity(0.1) : .clear, radius: 4, x: 0, y: 2)
//        .onAppear {
//            Task {
//                await viewModel.fetchKidData()
//                
//                if let selectedAgeRange = viewModel.selectedAgeRange {
//                    await viewModel.fetchAssessmentResultsIfNeeded(
//                        kidId: viewModel.selectedKidId,
//                        ageRangeId: selectedAgeRange.ageRangeId,
//                        assessmentTypeId: viewModel.selectedAssessmentType
//                    )
//                }
//            }
//        }
    }
}
