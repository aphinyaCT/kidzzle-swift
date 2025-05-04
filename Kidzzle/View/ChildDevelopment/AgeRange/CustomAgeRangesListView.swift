//
//  CustomAgeRangesListView.swift
//  Kidzzle
//
//  Created by aynnipa on 13/4/2568 BE.
//

import SwiftUI
import ScalingHeaderScrollView

// MARK: CustomAgeRangesList View
struct CustomAgeRangesListView: View {
    
    @ObservedObject var viewModel: ChildDevelopmentViewModel
    let selectedAssessmentType: String
    let onAgeRangeSelected: (AgeRangeData) -> Void
    let onDismiss: () -> Void
    
    private let cardBackgroundColors: [Color] = [
        .softPink,
        .sunYellow,
        .coralRed,
        .assetsPurple,
        .deepBlue,
        .greenMint
    ]
    
    private func getColorForIndex(_ index: Int) -> Color {
        let colorIndex = index % cardBackgroundColors.count
        return cardBackgroundColors[colorIndex]
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    @State var progress: CGFloat = 0
    
    private let minHeight = 100.0
    private let maxHeight = UIScreen.main.bounds.width > 700 ? 250.0 : 300.0
    
    var body: some View {
        GeometryReader { geometry in
            let columns = adaptiveColumns(for: geometry.size.width)
            ZStack {
                ScalingHeaderScrollView {
                    largeHeader(progress: progress)
                } content: {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 20)
                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            if viewModel.ageRanges.isEmpty {
                                EmptyView(message: "ไม่พบข้อมูลช่วงอายุ")
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else {
                                ForEach(Array(zip(viewModel.ageRanges.indices, viewModel.ageRanges)), id: \.1.ageRangeId) { index, ageRange in
                                    AgeRangeCard(
                                        ageRange: ageRange,
                                        bgColor: getColorForIndex(index),
                                        onTap: {
                                            onAgeRangeSelected(ageRange)
                                        }
                                    )
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
                            .foregroundColor(Color.white)
                            .padding(8)
                            .background(Color.jetblack)
                            .cornerRadius(10)
                    })
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    Text("การเฝ้าระวังและประเมินพัฒนาการ\(selectedAssessmentType == "ASSMTT_1" ? "เด็กทั่วไป" : "เด็กกลุ่มเสี่ยง") 5 ด้าน (\(selectedAssessmentType == "ASSMTT_1" ? "DSPM" : "DAIM"))")
                        .font(customFont(type: .bold, textStyle: .headline))
                        .foregroundColor(Color.jetblack)
                        .lineLimit(1)
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
                VStack(alignment: .leading, spacing: 10) {
                    Button(action: {
                        onDismiss()
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
                    
                    Text("การเฝ้าระวังและประเมินพัฒนาการ\(selectedAssessmentType == "ASSMTT_1" ? "เด็กทั่วไป" : "เด็กกลุ่มเสี่ยง") 5 ด้าน (\(selectedAssessmentType == "ASSMTT_1" ? "DSPM" : "DAIM"))")
                        .font(customFont(type: .bold, textStyle: .title2))
                        .lineLimit(UIScreen.main.bounds.width > 700 ? 1 : 2, reservesSpace: true)
                    
                    HStack(spacing: 16) {
                        Image(systemName: "exclamationmark.bubble.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.yellow)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                        
                        Text("การประเมินนี้อ้างอิงจากคู่มือ (\(selectedAssessmentType == "ASSMTT_1" ? "DSPM" : "DAIM")) พัฒนาการเด็กแต่ละคนอาจแตกต่างกัน หากมีข้อกังวลหรือพบว่ามีความล่าช้าควรปรึกษาผู้เชี่ยวชาญ")
                            .font(customFont(type: .regular, textStyle: .footnote))
                            .foregroundColor(.jetblack)
                            .fixedSize(horizontal: false, vertical: true)
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
    
    func adaptiveColumns(for width: CGFloat) -> [GridItem] {
        let columnCount = width > 700 ? 2 :
        width > 500 ? 2 : 2
        
        return Array(repeating:
                        GridItem(.flexible(), spacing: 20),
                     count: columnCount
        )
    }
}

// MARK: AgeRange Card
struct AgeRangeCard: View {
    let ageRange: AgeRangeData
    let bgColor: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            onTap()
        }, label: {
            VStack {
                HStack(alignment: .top) {
                    let displayText = if ageRange.ageRange == "แรกเกิด - 1 เดือน" || ageRange.ageRange == "แรกเกิด" {
                        ageRange.ageRange
                    } else {
                        StringHelper.removeParenthesesContent(from: ageRange.ageRange) + " เดือน"
                    }
                    
                    Text("ช่วงอายุ \n\(displayText)")
                        .font(customFont(type: .bold, textStyle: .subheadline))
                        .foregroundColor(Color.jetblack)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 16))
                        .foregroundColor(Color.jetblack)
                        .padding()
                        .frame(width: 32, height: 32)
                        .background(Color.white)
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                Spacer()
            }
        })
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 128)
        .background(bgColor)
        .cornerRadius(10)
    }
}
