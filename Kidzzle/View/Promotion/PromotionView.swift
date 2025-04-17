//
//  PromotionView.swift
//  Kidzzle
//
//  Created by aynnipa on 18/3/2568 BE.
//

import SwiftUI
import ScalingHeaderScrollView

struct PromotionView: View {
    
    @StateObject private var viewModel = PromotionViewModel()

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
                        
                        LazyVStack(spacing: 20) {
                            ForEach(viewModel.promotion) { promotion in
                                PromotionCard(promotion: promotion)
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
                    Image(systemName: "bolt.heart")
                        .font(.system(size: 16))
                        .frame(width: 16, height: 16)
                        .foregroundColor(Color.white)
                        .padding(8)
                        .background(Color.softPink)
                        .cornerRadius(10)
                    
                    Text("กิจกรรมส่งเสริมพัฒนาการเด็ก 5 ด้าน")
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
                    Image(systemName: "bolt.heart")
                        .font(.system(size: 24))
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color.white)
                        .padding(8)
                        .background(Color.softPink)
                        .cornerRadius(10)
                    
                    Text("กิจกรรมส่งเสริมพัฒนาการเด็ก 5 ด้าน")
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

struct PromotionCard: View {
    let promotion: Promotion
    @ObservedObject private var viewModel = PromotionViewModel()
    
    @State private var isShowingColorView = false
    @State private var isShowingBodyPartView = false
    
    let backgroundColors: [String: Color] = [
        "1": Color.deepBlue,
        "2": Color.assetsPurple
    ]
    
    let iconColors: [String: Color] = [
        "1": Color.softPink,
        "2": Color.sunYellow
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack (alignment: .center) {
                Image(systemName: promotion.sfIcon)
                    .font(.system(size: 56))
                    .foregroundColor(iconColors[promotion.id])

                VStack(alignment: .leading, spacing: 8) {
                    Text(promotion.title)
                        .font(customFont(type: .bold, textStyle: .headline))
                    
                    Text(promotion.textWarning)
                        .font(customFont(type: .regular, textStyle: .footnote))
                }
                .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    if promotion.id == "1" {
                        isShowingColorView = true
                    } else {
                        isShowingColorView = false
                        isShowingBodyPartView = true
                    }
                }, label: {
                    Image(systemName: "arrow.forward")
                        .font(.system(size: 20))
                        .foregroundColor(.jetblack)
                })
                .padding()
                .frame(width: 40, height: 40)
                .background(Color.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .frame(height: 128)
        .frame(maxWidth: .infinity)
        .background(backgroundColors[promotion.id])
        .cornerRadius(10)
        .onTapGesture {
            if promotion.id == "1" {
                isShowingColorView = true
            } else {
                isShowingBodyPartView = true
            }
        }
        .fullScreenCover(isPresented: $isShowingColorView) {
            ColorPromotionView(isPresented: $isShowingColorView)
        }
        .fullScreenCover(isPresented: $isShowingBodyPartView) {
            BodyPartPromotionView(isPresented: $isShowingBodyPartView)
        }
    }
}

#Preview {
    PromotionView()
}
