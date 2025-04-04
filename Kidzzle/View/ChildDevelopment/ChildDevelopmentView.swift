//
//  ChildDevelopmentView.swift
//  Kidzzle
//
//  Created by aynnipa on 28/3/2568 BE.
//

import SwiftUI
import SDWebImageSwiftUI
import ScalingHeaderScrollView

struct ChildDevelopmentView: View {
    
    @State private var selectedTab: Int = 0
    
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    @State var progress: CGFloat = 0
    
    private let minHeight = 120.0
    private let maxHeight = 180.0
    
    @StateObject private var viewModel = ChildDevelopmentViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var isPresented: Bool = false
    
    let developmentAreas = [
        (name: "ด้านการเคลื่อนไหว", icon: "figure.walk", color: Color.blue, progress: 0.75),
        (name: "ด้านกล้ามเนื้อมัดเล็ก", icon: "hand.draw", color: Color.green, progress: 0.6),
        (name: "ด้านการเข้าใจภาษา", icon: "ear", color: Color.orange, progress: 0.85),
        (name: "ด้านการใช้ภาษา", icon: "mouth", color: Color.purple, progress: 0.7),
        (name: "ด้านการช่วยเหลือตัวเอง", icon: "person.fill", color: Color.pink, progress: 0.5)
    ]
    
    var body: some View {
        ZStack {
            ScalingHeaderScrollView {
                largeHeader(progress: progress)
            } content: {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 20)
                    
                    // MARK: Carousel
                    ManualCarouselView()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    
                    // MARK: Assessment
                    VStack(alignment: .leading, spacing: 24) {
                        Text("การเฝ้าระวังและประเมินพัฒนาการ 5 ด้าน")
                            .font(customFont(type: .bold, textStyle: .headline))
                            .foregroundColor(.jetblack)
                        
                        // MARK: DSPM Button
                        AssessmentButton(
                            title: "ประเมิน DSPM",
                            subtitle: "ประเมินสำหรับเด็กทั่วไป",
                            imageName: "KIDZZLE-MASCOT",
                            backgroundColor: .softPink,
                            assessmentType: "ASSMTT_1",
                            destination: AnyView(AssessmentTypeView(assessmentType: "ASSMTT_1", isPresented: $isPresented))
                            // AnyView(SurveillanceChildrenView())
                        )
                        
                        HStack(spacing: 8) {
                            ForEach(0..<developmentAreas.count, id: \.self) { index in
                                let area = developmentAreas[index]
                                
                                CirclePercentProgress(
                                    progressPercentage: area.progress,
                                    iconName: area.icon,
                                    progressColor: area.color
                                )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        // MARK: DAIM Button
                        AssessmentButton(
                            title: "ประเมิน DAIM",
                            subtitle: "ประเมินสำหรับเด็กกลุ่มเสี่ยง",
                            imageName: "KIDZZLE-MASCOT",
                            backgroundColor: .sunYellow,
                            assessmentType: "ASSMTT_2",
                            destination: AnyView(AssessmentTypeView(assessmentType: "ASSMTT_2", isPresented: $isPresented))
                            //AnyView(SurveillanceChildrenView())
                        )
                        
                        HStack(spacing: 8) {
                            ForEach(0..<developmentAreas.count, id: \.self) { index in
                                let area = developmentAreas[index]
                                
                                CirclePercentProgress(
                                    progressPercentage: area.progress,
                                    iconName: area.icon,
                                    progressColor: area.color
                                )
                            }
                        }
                        .frame(maxWidth: .infinity)
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
        //.task {
        //    await viewModel.fetchPromotionBodyParts()
        //    viewModel.preloadImages()
        //}
    }
    
    private var smallHeader: some View {
        VStack {
            HStack(spacing: 16) {
                if progress >= 0.99 {
                    WebImage(url: URL(string: "https://res.cloudinary.com/dw7lzqrbz/image/upload/v1743320240/KIDZZLE-PROFILE_xtghbp.png"))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                    
                    Text("สวัสดี! pipokaitod@gmail.com") // ต้องเปลี่ยนค่า
                        .font(customFont(type: .bold, textStyle: .callout))
                        .tint(.jetblack)
                }
                
                Spacer()
                
                Button(action: {
                    authViewModel.signOut()
                }, label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.jetblack)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .cornerRadius(10)
                })
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            .padding(.horizontal, 20)
            .padding(.top, 48)
            
            Spacer()
        }
        .ignoresSafeArea()
    }
    
    private func largeHeader(progress: CGFloat) -> some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    WebImage(url: URL(string: "https://res.cloudinary.com/dw7lzqrbz/image/upload/v1743320240/KIDZZLE-PROFILE_xtghbp.png"))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                    
                    Spacer()
                    
                    VStack (alignment: .leading, spacing: 4) {
                        Text("สวัสดี, pipokaitod@gmail.com")
                            .font(customFont(type: .bold, textStyle: .headline))
                            .tint(.jetblack)
                        
                        HStack (spacing: 8) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 16))
                                .foregroundColor(.jetblack)
                            
                            Text(viewModel.currentThaiDate)
                                .font(customFont(type: .regular, textStyle: .headline))
                                .tint(.jetblack)
                        }
                        
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 120)
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(progress >= 1.0 ? 0 : 1)
                .offset(y: progress >= 1.0 ? -5 : 0)
                .animation(.easeOut(duration: 0.15), value: progress)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 24)
            
            Spacer()
        }
        .background(Color.ivorywhite)
    }
}

// MARK: Assessment Button
struct AssessmentButton: View {
    var title: String
    var subtitle: String
    var imageName: String
    var backgroundColor: Color
    var assessmentType: String
    var destination: AnyView
    
    var body: some View {
        NavigationLink(destination: destination) {
            ZStack {
                backgroundColor
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 56, height: 56)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .font(customFont(type: .bold, textStyle: .headline))
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .foregroundColor(.jetblack)
                            
                            Text(subtitle)
                                .font(customFont(type: .medium, textStyle: .caption1))
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .foregroundColor(.jetblack)
                        }
                        Spacer()
                        
                        Image(systemName: "arrow.forward")
                            .font(.system(size: 20))
                            .foregroundColor(.jetblack)
                            .padding()
                            .frame(width: 40, height: 40)
                            .background(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(16)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

//MARK: ManualCarouselView
struct ManualCarouselView: View {
    @StateObject private var viewModel = ChildDevelopmentViewModel()
    @State private var currentIndex: Int = 0
    
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(viewModel.manuals) { manual in
                cardView(for: manual)
                    .tag(manual.id)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(height: 230)
        .onReceive(timer) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % viewModel.manuals.count
            }
        }
    }
    
    @ViewBuilder
    func cardView(for manual: Manual) -> some View {
        VStack {
            HStack(alignment: .top, spacing: 10) {
                WebImage(url: URL(string: manual.imageURL))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 10) {
                    Text(manual.title)
                        .font(customFont(type: .bold, textStyle: .subheadline))
                        .lineLimit(2, reservesSpace: true)
                    
                    Text(manual.subtitle)
                        .font(customFont(type: .bold, textStyle: .caption2))
                        .lineLimit(3, reservesSpace: true)
                }
                .foregroundColor(.white)
                .multilineTextAlignment(.trailing)
            }
            
            Spacer()
            
            Text(manual.detail)
                .font(customFont(type: .medium, textStyle: .footnote))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.leading)
                .lineLimit(3, reservesSpace: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .frame(height: 230)
        .background(manual.backgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

//// MARK: Circle Percent Progress
//struct CirclePercentProgress: View {
//    @ObservedObject var viewModel = ChildDevelopmentViewModel()
//    var topicIndex: Int
//
//    @State private var fillAmount: CGFloat = 0
//    @State private var percentage: Int = 0
//
//    var body: some View {
//        let topic = viewModel.developmentCards[topicIndex]
//        let progressAmount = topic.progressAmount
//        let maxAmount = Double(topic.amountofTest) ?? 1.0
//
//        ZStack {
//            Circle()
//                .stroke(lineWidth: 4)
//                .frame(width: 40, height: 40)
//                .foregroundColor(.offwhite)
//
//            Circle()
//                .trim(from: 0, to: fillAmount)
//                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
//                .frame(width: 40, height: 40)
//                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [topic.progressColor]), startPoint: .topLeading, endPoint: .bottomTrailing))
//                .rotationEffect(.degrees(-90))
//
//            Image(systemName: topic.iconTopic)
//                .font(.system(size: 16))
//                .foregroundStyle(topic.progressColor)
//        }
//        .onAppear {
//            withAnimation(.easeInOut(duration: 1.0)) {
//                let progressPercentage = progressAmount / maxAmount
//                fillAmount = CGFloat(progressPercentage)
//                percentage = Int(progressPercentage * 100)
//            }
//        }
//    }
//}

// MARK: Circle Percent Progress
struct CirclePercentProgress: View {
    // แทนที่จะใช้ viewModel จริง ใช้พารามิเตอร์ที่ส่งเข้ามาแทน
    var progressPercentage: Double // 0.0 - 1.0
    var iconName: String
    var progressColor: Color
    
    @State private var fillAmount: CGFloat = 0
    @State private var percentage: Int = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 4)
                .frame(width: 40, height: 40)
                .foregroundColor(.gray.opacity(0.3)) // สีพื้นหลัง
            
            Circle()
                .trim(from: 0, to: fillAmount)
                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                .frame(width: 40, height: 40)
                .foregroundStyle(progressColor)
                .rotationEffect(.degrees(-90))
            
            Image(systemName: iconName)
                .font(.system(size: 16))
                .foregroundStyle(progressColor)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                fillAmount = CGFloat(progressPercentage)
                percentage = Int(progressPercentage * 100)
            }
        }
        .padding()
        .frame(width: 64, height: 64)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    ChildDevelopmentView()
}
