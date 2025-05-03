//
//  ColorPromotionView.swift
//  Kidzzle
//
//  Created by aynnipa on 12/3/2568 BE.
//

import SwiftUI
import ScalingHeaderScrollView

struct ColorPromotionView: View {
    @StateObject private var viewModel = ColorPromotionViewModel()
    @Binding var isPresented: Bool
    @State private var speechText: String = ""
    @State private var timer: Timer? = nil
    
    @State var progress: CGFloat = 0
    
    private let minHeight = 100.0
    private let maxHeight = 180.0
    
    var body: some View {
        ZStack {
            ScalingHeaderScrollView {
                largeHeader(progress: progress)
            } content: {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 20)
                    
                    if let currentColor = currentColor {
                        ColorPromotionCard(
                            colors: currentColor,
                            viewModel: viewModel,
                            speechText: $speechText,
                            progressScoreText: progressScoreText
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .height(min: minHeight, max: maxHeight)
            .collapseProgress($progress)
            .allowsHeaderGrowth()
            .background(Color.ivorywhite)
            
            smallHeader
        }
        .ignoresSafeArea()
        .task {
            viewModel.fetchPromotionColors()
            viewModel.preloadImages()
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
                    Text("สีแสนสนุก")
                        .font(customFont(type: .bold, textStyle: .headline))
                        .foregroundColor(.jetblack)
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
        .ignoresSafeArea()
    }
    
    private func largeHeader(progress: CGFloat) -> some View {
        VStack(spacing: 0) {
            ZStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("สีแสนสนุก")
                        .font(customFont(type: .bold, textStyle: .title2))
                        .foregroundColor(.jetblack)
                    
                    Text("เรียนรู้และฝึกออกเสียงชื่อสี เพื่อส่งเสริมทักษะด้านการเข้าใจภาษา (RL) และการใช้ภาษา (EL)")
                        .font(customFont(type: .regular, textStyle: .footnote))
                        .foregroundColor(.jetblack)
                        .lineLimit(2, reservesSpace: true)
                }
                .padding(.horizontal, 20)
                .padding(.top, 104)
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
    
    private var progressScoreText: String {
        return "\(viewModel.currentColorIndex + 1)/\(viewModel.colors.count)"
    }
    
    private var currentColor: PromotionColor? {
        if viewModel.colors.isEmpty || viewModel.currentColorIndex >= viewModel.colors.count { return nil }
        return viewModel.colors[viewModel.currentColorIndex]
    }
}


#Preview {
    ColorPromotionView(isPresented: .constant(false))
}
