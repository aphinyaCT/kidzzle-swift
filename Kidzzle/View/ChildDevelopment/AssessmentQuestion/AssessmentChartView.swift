//
//  AssessmentChartView.swift
//  Kidzzle
//
//  Created by aynnipa on 14/4/2568 BE.
//

import SwiftUI
import Charts

struct AssessmentChartView: View {
    @ObservedObject var viewModel: ChildDevelopmentViewModel
    
    var kidId: String
    var ageRangeId: String
    var assessmentTypeId: String
    
    @State private var isLoading = true
    @State private var selectedQuestionId: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isLoading {
                VStack {
                    ProgressView()
                }
                .frame(maxWidth: .infinity, alignment: .center)
            } else if viewModel.assessmentResults.isEmpty {
                EmptyView(message: "ไม่พบข้อมูลผลการประเมิน")
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                if let selectedId = selectedQuestionId {
                    questionResultChart(questionId: selectedId)
                } else {
                    EmptyView(message: "ไม่พบข้อมูลผลการประเมิน")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .padding(.bottom, 40)
        .refreshable {
            Task {
                await loadData()
            }
        }
        .onAppear {
            Task {
                await loadData()
            }
        }
    }
    
    private func questionResultChart(questionId: String) -> some View {
        let questionResults = getQuestionResults(questionId: questionId)
        _ = getDevelopmentType(for: questionId)
        let domainFullName = getDomainFullName(for: questionId)
        
        return VStack(alignment: .leading, spacing: 24) {
            
            Text("ประเภท: \(domainFullName)")
                .font(customFont(type: .bold, textStyle: .body))
                .foregroundColor(.jetblack)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(uniqueQuestionIds, id: \.self) { questionId in
                        let developmentType = getDevelopmentType(for: questionId)
                        let assessmentNo = getAssessmentNo(for: questionId)
                        Button(action: {
                            selectedQuestionId = questionId
                        }) {
                            Text("\(assessmentNo). \(developmentType)")
                                .font(customFont(type: .bold, textStyle: .body))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedQuestionId == questionId ? getDomainColor(for: questionId) : Color.gray.opacity(0.2))
                                .foregroundColor(selectedQuestionId == questionId ? .white : .primary)
                                .cornerRadius(20)
                        }
                    }
                }
            }
            
            if questionResults.isEmpty {
                EmptyView(message: "ไม่พบข้อมูลการประเมินสำหรับด้านนี้")
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    Chart {
                        ForEach(questionResults.sorted { $0.createdAt < $1.createdAt }) { result in
                            LineMark(
                                x: .value("วันที่", result.createdAt),
                                y: .value("ผลการประเมิน", result.isPassed ? 1 : 0)
                            )
                            .foregroundStyle(getDomainColor(for: questionId))
                            .lineStyle(StrokeStyle(lineWidth: 2))
                            
                            PointMark(
                                x: .value("วันที่", result.createdAt),
                                y: .value("ผลการประเมิน", result.isPassed ? 1 : 0)
                            )
                            .foregroundStyle(result.isPassed ? Color.green : Color.red)
                            .symbolSize(100)
                        }
                        
                        RuleMark(y: .value("ผ่าน", 0.5))
                            .foregroundStyle(.gray.opacity(0.5))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    }
                    .chartYScale(domain: 0...1)
                    .chartYAxis {
                        AxisMarks(values: [0, 1]) { value in
                            AxisValueLabel {
                                Text(value.index == 0 ? "ไม่ผ่าน" : "ผ่าน")
                                    .font(customFont(type: .regular, textStyle: .body))
                                    .foregroundColor(value.index == 0 ? .red : .green)
                            }
                        }
                    }
                    .chartXAxis {
                        let dates = questionResults.map { $0.createdAt }.sorted()
                        AxisMarks(values: dates) { value in
                            if let date = value.as(Date.self) {
                                AxisValueLabel {
                                    Text(formatShortDate(date))
                                        .font(customFont(type: .regular, textStyle: .caption1))
                                }
                                .offset(y: 5)
                            }
                        }
                    }
                    .frame(
                        width: max(UIScreen.main.bounds.width, CGFloat(questionResults.count) * 100),
                        height: 300
                    )
                    .padding()
                }
                .frame(height: 300)
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    HStack {
                        Text("ประวัติการประเมิน:")
                            .font(customFont(type: .bold, textStyle: .body))
                            .foregroundColor(.jetblack)
                        
                        Spacer()
                        
                        Button(action: {
                            Task {
                                await loadData()
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 16))
                                .foregroundColor(.jetblack)
                        }
                    }
                    
                    if questionResults.isEmpty {
                        EmptyView(message: "ไม่พบประวัติการประเมิน")
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(questionResults.sorted(by: { $0.createdAt > $1.createdAt })) { result in
                                    HStack {
                                        Circle()
                                            .fill(result.isPassed ? Color.green : Color.red)
                                            .frame(width: 8, height: 8)
                                        
                                        Text(result.createdAt.currentDateString())
                                            .font(customFont(type: .regular, textStyle: .body))
                                        
                                        Spacer()
                                        
                                        Text(result.isPassed ? "ผ่าน" : "ไม่ผ่าน")
                                            .font(customFont(type: .regular, textStyle: .body))
                                            .foregroundColor(result.isPassed ? .green : .red)
                                    }
                                    .padding(8)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack (spacing: 8) {
                        Image(systemName: "exclamationmark.bubble.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.yellow)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                        
                        Text("คำแนะนำหลังการประเมิน")
                            .font(customFont(type: .bold, textStyle: .body))
                            .foregroundColor(.jetblack)
                    }
                    
                    Text("• กรณีประเมินแล้วพบว่าสมวัย")
                        .font(customFont(type: .bold, textStyle: .body))
                    
                    Text("แนะนำให้ส่งเสริมพัฒนาการเด็กในช่วงอายุต่อไปตามคู่มือฯ")
                        .font(customFont(type: .regular, textStyle: .body))
                    
                    Text("• กรณีที่เด็กประเมินแล้วพบว่าไม่สมวัย")
                        .font(customFont(type: .bold, textStyle: .body))
                    
                    Text("ส่งเสริมพัฒนาการเด็กตามคู่มือฯ ในข้อทักษะที่เด็กไม่ผ่านการประเมินบ่อย ๆ หลังจากนั้นอีก 1 เดือน กลับมาประเมินซ้ำ")
                        .font(customFont(type: .regular, textStyle: .body))
                    
                    Text("• กรณีประเมินซ้ำแล้วยังไม่สมวัย")
                        .font(customFont(type: .bold, textStyle: .body))

                    Text("ส่งต่อตรวจและวินิจฉัยเพิ่มเติมที่โรงพยาบาล (รพช./รพท./ รพศ./รพ.จิตเวช) พร้อมใบส่งตัว")
                        .font(customFont(type: .regular, textStyle: .body))
                }
                .foregroundColor(.jetblack)
                .fixedSize(horizontal: false, vertical: true)
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
    }
    
    private func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d/M"
        return formatter.string(from: date)
    }
    
    private var uniqueQuestionIds: [String] {
        let results = getFilteredResults()
        let questionIds = Set(results.map { $0.assessmentQuestionId })
        
        if assessmentTypeId == "ASSMTT_1" {
            return Array(questionIds).sorted { questionId1, questionId2 in
                let no1 = extractNumber(from: getAssessmentNo(for: questionId1))
                let no2 = extractNumber(from: getAssessmentNo(for: questionId2))
                return no1 < no2
            }
        } else {
            let daimOrder = ["GM", "FM", "RL", "EL", "PS"]
            
            return Array(questionIds).sorted { questionId1, questionId2 in
                let type1 = getDevelopmentType(for: questionId1)
                let type2 = getDevelopmentType(for: questionId2)
                
                if type1 == type2 {
                    let no1 = extractNumber(from: getAssessmentNo(for: questionId1))
                    let no2 = extractNumber(from: getAssessmentNo(for: questionId2))
                    return no1 < no2
                }
                
                let index1 = daimOrder.firstIndex(of: type1) ?? daimOrder.count
                let index2 = daimOrder.firstIndex(of: type2) ?? daimOrder.count
                
                return index1 < index2
            }
        }
    }
    
    private func extractNumber(from assessmentNo: String) -> Int {
        if let number = Int(assessmentNo.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
            return number
        }
        return 999
    }
    
    private func getQuestionResults(questionId: String) -> [AssessmentResult] {
        return getFilteredResults().filter { $0.assessmentQuestionId == questionId }
    }
    
    private func getFilteredResults() -> [AssessmentResult] {
        return viewModel.assessmentResults.filter {
            $0.kidId == kidId &&
            $0.ageRangeId == ageRangeId &&
            $0.assessmentTypeId == assessmentTypeId
        }
    }
    
    private func getDevelopmentType(for questionId: String) -> String {
        if let question = viewModel.assessmentQuestions.first(where: { $0.assessmentQuestionId == questionId }) {
            return question.developmentType
        }
        return "ไม่พบประเภทของพัฒนาการ"
    }
    
    private func getAssessmentNo(for questionId: String) -> String {
        if let question = viewModel.assessmentQuestions.first(where: { $0.assessmentQuestionId == questionId }) {
            return question.assessmentNo
        }
        return "?"
    }
    
    private func getDomainFullName(for questionId: String) -> String {
        let type = getDevelopmentType(for: questionId)
        return DevelopmentTypeHelper.getFullName(type)
    }
    
    private func getDomainColor(for questionId: String) -> Color {
        let type = getDevelopmentType(for: questionId)
        return DevelopmentTypeHelper.getColor(type)
    }
    
    private func loadData() async {
        isLoading = true
        
        await viewModel.fetchAssessmentResultsIfNeeded(
            kidId: kidId,
            ageRangeId: ageRangeId,
            assessmentTypeId: assessmentTypeId
        )
        
        if !viewModel.assessmentResults.isEmpty {
            let firstResult = getFilteredResults().first
            selectedQuestionId = firstResult?.assessmentQuestionId
        }
        
        isLoading = false
    }
}
