//
//  PromotionView.swift
//  Kidzzle
//
//  Created by aynnipa on 18/3/2568 BE.
//

import SwiftUI

struct PromotionView: View {
    @StateObject private var viewModel = PromotionViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.ivorywhite
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                Text("กิจกรรมส่งเสริมพัฒนาการเด็ก 5 ด้าน")
                    .font(customFont(type: .bold, textStyle: .title2))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 20)
                
                LazyVStack(spacing: 20) {
                    ForEach(viewModel.promotion) { promotion in
                        PromotionCard(promotion: promotion)
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 20)
            .padding(.horizontal, 20)
        }
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
            HStack {
                Image(systemName: promotion.sfIcon)
                    .font(.system(size: 56))
                    .foregroundColor(iconColors[promotion.id])
                
                Spacer()
                
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
                .frame(alignment: .trailingLastTextBaseline)
            }
        }
        .padding()
        .frame(height: 128)
        .frame(maxWidth: .infinity)
        .background(backgroundColors[promotion.id])
        .cornerRadius(10)
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
