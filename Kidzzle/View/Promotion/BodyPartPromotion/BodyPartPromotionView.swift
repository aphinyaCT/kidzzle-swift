//
//  BodyPartPromotionView.swift
//  Kidzzle
//
//  Created by aynnipa on 13/3/2568 BE.
//

import SwiftUI
import ScalingHeaderScrollView

struct BodyPartPromotionView: View {
    @StateObject private var viewModel = BodyPartPromotionViewModel()
    @Binding var isPresented: Bool
    
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    @State var progress: CGFloat = 0
    
    private let minHeight = 100.0
    private let maxHeight = 300.0
    
    var body: some View {
        ZStack {
            ScalingHeaderScrollView {
                largeHeader(progress: progress)
            } content: {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 20)
                    
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.bodyParts) { bodyPart in
                            BodyPartPromotionCard(bodyPart: bodyPart, viewModel: viewModel)
                                .id(bodyPart.id)
                                .onTapGesture {
                                    viewModel.playPromotionBodyPartAudio(for: bodyPart)
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
        .task {
            await viewModel.fetchPromotionBodyParts()
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
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.jetblack)
                        .cornerRadius(10)
                })
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                if progress >= 0.99 {
                    Text("อวัยวะอะไรเอ่ย?")
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
                    Text("อวัยวะอะไรเอ่ย?")
                        .font(customFont(type: .bold, textStyle: .title2))
                        .foregroundColor(.jetblack)
                    
                    Text("เรียนรู้และทำตามคำสั่งชี้ตามอวัยวะต่าง ๆ เพื่อส่งเสริมทักษะด้านการเข้าใจภาษา (RL) และการใช้ภาษา (EL)")
                        .font(customFont(type: .regular, textStyle: .footnote))
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
                
                Text("พัฒนาการของเด็กแต่ละคนไม่เท่ากัน ดังนั้นสิ่งสำคัญคือความสม่ำเสมอในการฝึกฝนทักษะดังกล่าว โดยไม่เร่งรัดหรือกดดันตัวเด็ก")
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
                    .stroke(Color.jetblack, lineWidth: 1)
            )
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 24)
            .opacity(progress >= 0.8 ? 0 : 1)
            .offset(y: progress >= 0.8 ? 8 : 0)
            .animation(.easeInOut(duration: 0.18), value: progress)
            
            Spacer()
        }
        .background(Color.softPink)
    }
}

struct BodyPartPromotionCard: View {
    let bodyPart: PromotionBodyPart
    @ObservedObject var viewModel: BodyPartPromotionViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                if let imageURL = viewModel.getFormattedImageURL(for: bodyPart) {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                    } placeholder: {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray.opacity(0.5))
                    }
                } else {
                    Image(systemName: "questionmark.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                        .frame(width: 100, height: 100)
                }
                
                VStack(spacing: 12) {
                    Text(bodyPart.name)
                        .font(customFont(type: .bold, textStyle: .headline))
                        .foregroundColor(.jetblack)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                    
                    Button(action: {
                        viewModel.playPromotionBodyPartAudio(for: bodyPart)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: viewModel.currentlyPlayingID == bodyPart.id ? "pause.circle.fill" : "play.circle.fill")
                                .foregroundColor(viewModel.currentlyPlayingID == bodyPart.id ? .coralRed : .deepBlue)
                            
                            Text(viewModel.currentlyPlayingID == bodyPart.id ? "หยุดเสียง" : "ฟังเสียง")
                                .font(customFont(type: .medium, textStyle: .callout))
                                .foregroundColor(viewModel.currentlyPlayingID == bodyPart.id ? .coralRed : .deepBlue)
                        }
                    }
                    .accessibilityLabel("เล่นเสียง \(bodyPart.name)")
                    .accessibilityHint("กดเพื่อฟังชื่ออวัยวะ")
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(20)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}

#Preview {
    BodyPartPromotionView(isPresented: .constant(false))
}
