//
//  CustomTrainingView.swift
//  Kidzzle
//
//  Created by aynnipa on 14/4/2568 BE.
//

import SwiftUI
import ScalingHeaderScrollView

struct CustomTrainingView: View {
    
    @ObservedObject var viewModel: ChildDevelopmentViewModel
    let question: AssessmentQuestionData
    let onDismiss: () -> Void
    @State private var isLoading = true
    
    @State var progress: CGFloat = 0
    
    private let minHeight = 100.0
    private let maxHeight = 150.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ScalingHeaderScrollView {
                    largeHeader(progress: progress)
                } content: {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 20)
                        
                        VStack(alignment: .leading, spacing: 24) {
                            if isLoading {
                                VStack {
                                    ProgressView()
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            } else {
                                if viewModel.developmentTrainings.isEmpty {
                                    EmptyView(message: "ไม่พบข้อมูลการฝึกทักษะ")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                } else {
                                    VStack(spacing: 16) {
                                        ForEach(viewModel.developmentTrainings, id: \.trainingMethodsId) { training in
                                            TrainingExpandingCard(viewModel: viewModel, question: question, training: training)
                                        }
                                    }
                                }
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
            .onAppear {
                isLoading = true
                Task {
                    await viewModel.fetchDevelopmentTrainings(questionId: question.assessmentQuestionId)
                    isLoading = false
                }
            }
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
                    
                    Text("วิธีการประเมินและฝึกทักษะ \(viewModel.selectedAssessmentType == "ASSMTT_1" ? "DSPM" : "DAIM")")
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
                    
                    Text("วิธีการประเมินและฝึกทักษะ \(viewModel.selectedAssessmentType == "ASSMTT_1" ? "DSPM" : "DAIM")")
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

// MARK: Training Expanding Card
struct TrainingExpandingCard: View {
    
    @ObservedObject var viewModel: ChildDevelopmentViewModel
    let question: AssessmentQuestionData
    let training: DevelopmentTrainingData
    @State private var isExpanded = true
    
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
                            .fill(Color.deepBlue.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "lightbulb.min")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.deepBlue)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("#\(training.assessmentNo)")
                            .font(customFont(type: .regular, textStyle: .caption1))
                            .foregroundColor(.gray)
                        
                        Text("วิธีฝึกทักษะ\(DevelopmentTypeHelper.getFullName(question.developmentType))")
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
                    
                    Text(StringHelper.cleanHtmlText(training.trainingText))
                        .font(customFont(type: .regular, textStyle: .body))
                        .foregroundColor(.jetblack)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                    HStack {
                        HStack {
                            Image(systemName: "shippingbox.fill")
                                .foregroundColor(.deepBlue)
                            
                            Text("อุปกรณ์ที่ใช้")
                                .font(customFont(type: .regular, textStyle: .body))
                                .foregroundColor(.deepBlue)
                        }
                        .padding()
                        .frame(height: 40)
                        .background(Color.deepBlue.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.deepBlue, lineWidth: 1)
                        )
                        .cornerRadius(10)
                        
                        Text("\(training.trainingRequiredTools ?? "ไม่ระบุ")")
                            .font(customFont(type: .regular, textStyle: .body))
                            .foregroundColor(.jetblack)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: isExpanded ? Color.black.opacity(0.1) : .clear, radius: 4, x: 0, y: 2)
    }
}
