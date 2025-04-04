////
////  AssesmentAgeRangeView.swift
////  Kidzzle
////
////  Created by aynnipa on 28/3/2568 BE.
////
//
//import SwiftUI
//import ScalingHeaderScrollView
//
//struct AssessmentTypeView: View {
//    
//    @State private var selectedTab: Int = 0
//    
//    private let columns = [
//        GridItem(.flexible(), spacing: 20),
//        GridItem(.flexible(), spacing: 20)
//    ]
//    
//    @State var progress: CGFloat = 0
//    
//    private let minHeight = 120.0
//    private let maxHeight = 320.0
//    
//    @StateObject private var viewModel = ChildDevelopmentViewModel()
//    
//    var assessmentType: String
//    @Binding var isPresented: Bool
//
//    var body: some View {
//        ZStack {
//            ScalingHeaderScrollView {
//                largeHeader(progress: progress)
//            } content: {
//                VStack(spacing: 0) {
//                    Color.clear.frame(height: 20)
//                    //
//                }
//            }
//            .height(min: minHeight, max: maxHeight)
//            .collapseProgress($progress)
//            .allowsHeaderGrowth()
//            .background(Color.ivorywhite)
//            
//            smallHeader
//        }
//        .ignoresSafeArea()
////        .task {
////            await viewModel.fetchPromotionBodyParts()
////            viewModel.preloadImages()
////        }
//    }
//    
//    private var smallHeader: some View {
//        VStack {
//            HStack(spacing: 16) {
//                Button(action: {
//                    isPresented.toggle()
//                }, label: {
//                    Image(systemName: "chevron.backward")
//                        .foregroundColor(.jetblack)
//                        .frame(width: 40, height: 40)
//                        .background(Color.white)
//                        .cornerRadius(10)
//                })
//                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
//                
//                if progress >= 0.99 {
//                    Text("การเฝ้าระวังและประเมินพัฒนาการเด็กทั่วไป 5 ด้าน (DSPM)")
//                        .font(customFont(type: .bold, textStyle: .headline))
//                        .foregroundColor(.jetblack)
//                        .transition(
//                            .opacity
//                                .combined(with: .offset(y: -8))
//                        )
//                        .animation(.easeInOut(duration: 0.12), value: progress)
//                }
//                
//                Spacer()
//            }
//            .padding(.leading, 20)
//            .padding(.top, 48)
//            
//            Spacer()
//        }
//        .ignoresSafeArea()
//    }
//    
//    private func largeHeader(progress: CGFloat) -> some View {
//        VStack(spacing: 0) {
//            ZStack {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("การเฝ้าระวังและประเมินพัฒนาการเด็กทั่วไป 5 ด้าน (DSPM)")
//                        .font(customFont(type: .bold, textStyle: .title2))
//                        .foregroundColor(.jetblack)
//                        .lineLimit(2, reservesSpace: true)
//
//                }
//                .padding(.horizontal, 20)
//                .padding(.top, 112)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .opacity(progress >= 1.0 ? 0 : 1)
//                .offset(y: progress >= 1.0 ? -5 : 0)
//                .animation(.easeOut(duration: 0.15), value: progress)
//            }
//            .frame(maxWidth: .infinity)
//            
//            HStack(spacing: 10) {
//                Image(systemName: "exclamationmark.bubble.fill")
//                    .font(.system(size: 24))
//                    .foregroundColor(.sunYellow)
//                
//                Text("การประเมินนี้อ้างอิงจากคู่มือ DSPM สำหรับเด็กทั่วไป พัฒนาการของเด็กแต่ละคนอาจแตกต่างกัน ผู้ปกครองควรกระตุ้นทักษะอย่างต่อเนื่อง หากพบความผิดปกติควรปรึกษาผู้เชี่ยวชาญโดยเร็ว")
//                    .font(customFont(type: .regular, textStyle: .footnote))
//                    .foregroundColor(.jetblack)
//                    .fixedSize(horizontal: false, vertical: true)
//            }
//            .padding()
//            .background(Color.white)
//            .cornerRadius(10)
//            .overlay(
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(Color.jetblack, lineWidth: 1)
//            )
//            .padding(.horizontal, 16)
//            .padding(.top, 16)
//            .padding(.bottom, 24)
//            .opacity(progress >= 0.8 ? 0 : 1)
//            .offset(y: progress >= 0.8 ? 8 : 0)
//            .animation(.easeInOut(duration: 0.18), value: progress)
//            
//            Spacer()
//        }
//        .background(Color.greenMint)
//    }
//}
//
//#Preview {
//    AssessmentTypeView(assessmentType: "", isPresented: .constant(false))
//}

import SwiftUI
import ScalingHeaderScrollView

struct AssessmentTypeView: View {
    @State private var selectedTab: Int = 0 // 0 = 0-2ปี, 1 = 2-4ปี, 2 = 4-6ปี
    @State var progress: CGFloat = 0
    
    private let minHeight = 120.0
    private let maxHeight = 320.0
    
    @StateObject private var viewModel = ChildDevelopmentViewModel()
    
    var assessmentType: String
    @Binding var isPresented: Bool
    
    // สีสำหรับการ์ดแต่ละช่วงอายุ
    let cardColors: [Color] = [
        Color(UIColor(red: 0.91, green: 0.54, blue: 0.84, alpha: 1)), // สีชมพู
        Color(UIColor(red: 0.98, green: 0.77, blue: 0.37, alpha: 1)), // สีเหลือง
        Color(UIColor(red: 0.96, green: 0.49, blue: 0.38, alpha: 1)), // สีส้ม
        Color(UIColor(red: 0.58, green: 0.58, blue: 0.94, alpha: 1)), // สีม่วง
        Color(UIColor(red: 0.36, green: 0.61, blue: 0.97, alpha: 1)), // สีฟ้า
        Color(UIColor(red: 0.42, green: 0.76, blue: 0.54, alpha: 1))  // สีเขียว
    ]
    
    var body: some View {
        ZStack {
            ScalingHeaderScrollView {
                largeHeader(progress: progress)
            } content: {
                VStack(spacing: 16) {
                    Color.clear.frame(height: 10)
                    
                    // Age Range Tab Selector
                    ageRangeTabSelector
                        .padding(.horizontal, 20)
                    
                    // Age Range Cards Grid
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else if viewModel.ageRanges.isEmpty {
                        Text(viewModel.errorMessage ?? "ไม่พบข้อมูลช่วงอายุ")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ageRangeCardsGrid
                    }
                    
                    Spacer(minLength: 40)
                }
            }
            .height(min: minHeight, max: maxHeight)
            .collapseProgress($progress)
            .allowsHeaderGrowth()
            .background(Color.white)
            
            smallHeader
        }
        .ignoresSafeArea()
        .onAppear {
            viewModel.selectAssessmentType(assessmentType)
        }
    }
    
    private var smallHeader: some View {
        VStack {
            HStack(spacing: 16) {
                Button(action: {
                    isPresented.toggle()
                }, label: {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.jetblack)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .cornerRadius(10)
                })
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                if progress >= 0.99 {
                    let isTypeDSPM = assessmentType == "ASSMTT_1"
                    let title = isTypeDSPM ? "DSPM" : "DAIM"
                    
                    Text(title)
                        .font(customFont(type: .bold, textStyle: .headline))
                        .foregroundColor(.jetblack)
                        .transition(.opacity.combined(with: .offset(y: -8)))
                        .animation(.easeInOut(duration: 0.12), value: progress)
                }
                
                Spacer()
            }
            .padding(.leading, 20)
            .padding(.top, 48)
            
            Spacer()
        }
        .ignoresSafeArea()
    }
    
    private func largeHeader(progress: CGFloat) -> some View {
        let isTypeDSPM = assessmentType == "ASSMTT_1"
        let title = isTypeDSPM ? "DSPM" : "DAIM"
        let fullTitle = isTypeDSPM
            ? "การเฝ้าระวังและส่งเสริมพัฒนาการเด็กทั่วไป (DSPM)"
            : "การประเมินและส่งเสริมพัฒนาการเด็กกลุ่มเสี่ยง (DAIM)"
        
        return VStack(spacing: 0) {
            ZStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(fullTitle)
                        .font(customFont(type: .bold, textStyle: .title2))
                        .foregroundColor(.jetblack)
                        .lineLimit(2, reservesSpace: true)
                }
                .padding(.horizontal, 20)
                .padding(.top, 112)
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(progress >= 1.0 ? 0 : 1)
                .offset(y: progress >= 1.0 ? -5 : 0)
                .animation(.easeOut(duration: 0.15), value: progress)
            }
            .frame(maxWidth: .infinity)
            
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.bubble.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.sunYellow)
                
                Text("พัฒนาการเด็กแต่ละคนแตกต่างกัน หากพบความผิดปกติควรปรึกษาผู้เชี่ยวชาญโดยเร็ว")
                    .font(customFont(type: .regular, textStyle: .footnote))
                    .foregroundColor(.jetblack)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.jetblack, lineWidth: 1))
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 24)
            .opacity(progress >= 0.8 ? 0 : 1)
            .offset(y: progress >= 0.8 ? 8 : 0)
            .animation(.easeInOut(duration: 0.18), value: progress)
            
            Spacer()
        }
        .background(isTypeDSPM ? Color.greenMint : Color.sunYellow.opacity(0.3))
    }
    
    // เลือกช่วงอายุแบบแท็บ
    private var ageRangeTabSelector: some View {
        HStack(spacing: 0) {
            Button(action: { selectedTab = 0 }) {
                HStack {
                    Image(systemName: "face.smiling")
                        .foregroundColor(selectedTab == 0 ? .white : .gray)
                    Text("0 - 2 ปี")
                        .foregroundColor(selectedTab == 0 ? .white : .gray)
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(selectedTab == 0 ? Color.black : Color.clear)
            }
            .background(selectedTab == 0 ? Color.black : Color.gray.opacity(0.2))
            .clipShape(RoundedCorner(radius: 12, corners: [.topLeft, .bottomLeft]))
            
            Button(action: { selectedTab = 1 }) {
                HStack {
                    Image(systemName: "face.smiling")
                        .foregroundColor(selectedTab == 1 ? .white : .gray)
                    Text("2 - 4 ปี")
                        .foregroundColor(selectedTab == 1 ? .white : .gray)
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(selectedTab == 1 ? Color.black : Color.clear)
            }
            .background(selectedTab == 1 ? Color.black : Color.gray.opacity(0.2))
            
            Button(action: { selectedTab = 2 }) {
                HStack {
                    Image(systemName: "face.smiling")
                        .foregroundColor(selectedTab == 2 ? .white : .gray)
                    Text("4 - 6 ปี")
                        .foregroundColor(selectedTab == 2 ? .white : .gray)
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(selectedTab == 2 ? Color.black : Color.clear)
            }
            .background(selectedTab == 2 ? Color.black : Color.gray.opacity(0.2))
            .clipShape(RoundedCorner(radius: 12, corners: [.topRight, .bottomRight]))
        }
        .font(customFont(type: .medium, textStyle: .subheadline))
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .onChange(of: selectedTab) { newValue in
            // กรองช่วงอายุตามแท็บที่เลือก
            filterAgeRangesByTab(tab: newValue)
        }
    }
    
    // กรองช่วงอายุตามแท็บที่เลือก (0-2ปี, 2-4ปี, 4-6ปี)
    private func filterAgeRangesByTab(tab: Int) {
        // คำนวณช่วงอายุในหน่วยเดือนสำหรับแต่ละแท็บ
        let minMonths: Int
        let maxMonths: Int
        
        switch tab {
        case 0: // 0-2 ปี
            minMonths = 0
            maxMonths = 24
        case 1: // 2-4 ปี
            minMonths = 25
            maxMonths = 48
        case 2: // 4-6 ปี
            minMonths = 49
            maxMonths = 72
        default:
            minMonths = 0
            maxMonths = 24
        }
        
        // โหลดข้อมูลใหม่ตามช่วงอายุที่เลือก
        Task {
            await viewModel.fetchAgeRanges(assessmentType: assessmentType)
        }
    }
    
    // กริดการ์ดช่วงอายุ
    private var ageRangeCardsGrid: some View {
        // กรองช่วงอายุตามแท็บที่เลือก
        let filteredRanges = viewModel.ageRanges.filter { ageRange in
            let minMonths = Int(ageRange.minMonths) ?? 0
            let maxMonths = Int(ageRange.maxMonths) ?? 0
            
            switch selectedTab {
            case 0: // 0-2 ปี
                return maxMonths <= 24
            case 1: // 2-4 ปี
                return minMonths >= 24 && maxMonths <= 48
            case 2: // 4-6 ปี
                return minMonths >= 48 && maxMonths <= 72
            default:
                return true
            }
        }
        
        return LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
            ForEach(Array(filteredRanges.enumerated()), id: \.element.id) { index, ageRange in
                NavigationLink(destination: AgeRangeQuestionsView(ageRange: ageRange, assessmentType: assessmentType)) {
                    AgeRangeCard(
                        title: "ช่วงอายุ \(ageRange.minMonths) - \(ageRange.maxMonths) เดือน",
                        progress: 0, // จะเพิ่มความคืบหน้าจริงในภายหลัง
                        total: 5,   // จำนวนคำถามทั้งหมด (ควรดึงจากข้อมูลจริง)
                        color: cardColors[index % cardColors.count]
                    )
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// การ์ดแสดงช่วงอายุ
struct AgeRangeCard: View {
    var title: String
    var progress: Int
    var total: Int
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(customFont(type: .bold, textStyle: .subheadline))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Spacer()
                
                Image(systemName: "arrow.up.forward.square")
                    .foregroundColor(.white)
                    .font(.system(size: 18))
            }
            
            Text("ข้อคำถาม")
                .font(customFont(type: .regular, textStyle: .caption1))
                .foregroundColor(.white.opacity(0.8))
            
            ProgressView(value: Double(progress), total: Double(total))
                .progressViewStyle(LinearProgressViewStyle(tint: .white))
                .background(Color.white.opacity(0.3))
                .cornerRadius(5)
            
            HStack {
                Spacer()
                Text("\(progress)/\(total)")
                    .font(customFont(type: .medium, textStyle: .caption1))
                    .foregroundColor(.white)
            }
        }
        .padding()
        .frame(height: 130)
        .background(color)
        .cornerRadius(12)
    }
}

// หน้าแสดงรายการคำถามสำหรับช่วงอายุที่เลือก
struct AgeRangeQuestionsView: View {
    var ageRange: AssessmentAgeRangeResponse
    var assessmentType: String
    @StateObject private var viewModel = ChildDevelopmentViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            } else if viewModel.assessmentQuestions.isEmpty {
                Text(viewModel.errorMessage ?? "ไม่พบข้อคำถามสำหรับช่วงอายุนี้")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(viewModel.assessmentQuestions) { question in
                        NavigationLink(destination: AssessmentQuestionDetailView(question: question)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("ข้อ \(question.assessmentNo): \(question.developmentType)")
                                    .font(customFont(type: .bold, textStyle: .subheadline))
                                
                                Text(question.questionText)
                                    .font(customFont(type: .regular, textStyle: .caption1))
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationTitle("ช่วงอายุ \(ageRange.minMonths)-\(ageRange.maxMonths) เดือน")
        .onAppear {
            Task {
                await viewModel.fetchAssessmentQuestions(assessmentType: assessmentType, ageRangeId: ageRange.id)
            }
        }
    }
}

// หน้ารายละเอียดคำถาม
struct AssessmentQuestionDetailView: View {
    var question: AssessmentQuestionResponse
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(question.developmentType)
                    .font(customFont(type: .bold, textStyle: .headline))
                    .foregroundColor(.primary)
                
                Text("ข้อ \(question.assessmentNo)")
                    .font(customFont(type: .bold, textStyle: .title3))
                    .foregroundColor(.primary)
                
                Text(question.questionText)
                    .font(customFont(type: .regular, textStyle: .body))
                    .foregroundColor(.primary)
                    .padding(.bottom, 8)
                
                Divider()
                
                Group {
                    Text("วิธีประเมิน")
                        .font(customFont(type: .bold, textStyle: .headline))
                        .foregroundColor(.primary)
                    
                    Text(question.assessmentMethod)
                        .font(customFont(type: .regular, textStyle: .body))
                        .foregroundColor(.primary)
                }
                .padding(.bottom, 8)
                
                if !question.assessmentRequiredTool.isEmpty {
                    Group {
                        Text("อุปกรณ์ที่ใช้")
                            .font(customFont(type: .bold, textStyle: .headline))
                            .foregroundColor(.primary)
                        
                        Text(question.assessmentRequiredTool)
                            .font(customFont(type: .regular, textStyle: .body))
                            .foregroundColor(.primary)
                    }
                    .padding(.bottom, 8)
                }
                
                Group {
                    Text("เกณฑ์ผ่าน")
                        .font(customFont(type: .bold, textStyle: .headline))
                        .foregroundColor(.primary)
                    
                    Text(question.passCriteria)
                        .font(customFont(type: .regular, textStyle: .body))
                        .foregroundColor(.primary)
                }
                
                Spacer(minLength: 40)
                
                HStack {
                    Button(action: {
                        // บันทึกว่าไม่ผ่าน
                    }) {
                        Text("ไม่ผ่าน")
                            .font(customFont(type: .bold, textStyle: .body))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        // บันทึกว่าผ่าน
                    }) {
                        Text("ผ่าน")
                            .font(customFont(type: .bold, textStyle: .body))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("รายละเอียดคำถาม")
    }
}

// Helper shape
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// Preview
#Preview {
    AssessmentTypeView(assessmentType: "ASSMTT_1", isPresented: .constant(false))
}
