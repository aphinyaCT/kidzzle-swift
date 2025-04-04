//
//  BenefitView.swift
//  Kidzzle
//
//  Created by aynnipa on 14/3/2568 BE.
//

import SwiftUI
import ScalingHeaderScrollView
import UIKit

struct BenefitView: View {
    
    @State private var progress: CGFloat = 0
    
        private let minHeight = 100.0
        private let maxHeight = 200.0
    
    var body: some View {
        ZStack {
            ScalingHeaderScrollView {
                largeHeader(progress: progress)
            } content: {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 20)
                    
                    NHSOBenefitView()
                    MSDHSBenefitView()
                }
                .padding(.bottom, 40)
            }
            .height(min: minHeight, max: maxHeight)
            .collapseProgress($progress)
            .allowsHeaderGrowth()
            .background(Color.ivorywhite)
            
            smallHeader
        }
        .ignoresSafeArea(.container, edges: [.top, .horizontal])
    }
    
    private var smallHeader: some View {
        VStack {
            HStack(spacing: 16) {
                if progress >= 0.99 {
                    Image(systemName: "cross.case")
                        .font(.system(size: 16))
                        .frame(width: 16, height: 16)
                        .foregroundColor(Color.white)
                        .padding(8)
                        .background(Color.coralRed)
                        .cornerRadius(10)
                    
                    Text("สวัสดิการทางสุขภาพและการเงิน")
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
                    Image(systemName: "cross.case")
                        .font(.system(size: 24))
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color.white)
                        .padding(8)
                        .background(Color.coralRed)
                        .cornerRadius(10)
                    
                    Text("สวัสดิการทางสุขภาพและการเงิน")
                        .font(customFont(type: .bold, textStyle: .title2))
                    
                    Text("หน่วยงานที่เกี่ยวข้องกับพัฒนาการเด็กและชีวิตความเป็นอยู่")
                        .font(customFont(type: .regular, textStyle: .footnote))
                        .lineLimit(2, reservesSpace: true)
                }
                .foregroundColor(Color.jetblack)
                .padding(.horizontal, 20)
                .padding(.top, 96)
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

// MARK: - NHSO Benefit View

struct NHSOBenefitView: View {
    @ObservedObject private var viewModel = BenefitViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("สิทธิหลักประกันสุขภาพแห่งชาติ (NHSO)")
                .font(customFont(type: .bold, textStyle: .headline))
            
            ServiceButtonView(
                title: "ตรวจสอบสิทธิบัตรทอง 30 บาท",
                imageName: "id-card",
                backgroundColor: .softPink,
                urlString: viewModel.urls.nhsoCheck,
                viewModel: viewModel
            )
            
            ExpandingCardView(
                sfIcon: "pencil",
                title: "เอกสารลงทะเบียนบัตรทอง",
                contentType: .custom(AnyView(
                    DocumentListView(sections: viewModel.documentNHSO)
                )),
                iconColor: .greenMint,
                backgroundColor: .greenMint.opacity(0.2)
            )
            
            ExpandingCardView(
                sfIcon: "heart.text.clipboard.fill",
                title: "สิทธิประโยชน์",
                contentType: .bulletPoints(viewModel.benefitNHSO),
                iconColor: .coralRed,
                backgroundColor: .coralRed.opacity(0.2)
            )
            
            ExpandingCardView(
                sfIcon: "document.badge.plus.fill",
                title: "ช่องทางการลงทะเบียน",
                contentType: .bulletPoints(viewModel.contactNHSO),
                iconColor: .sunYellow,
                backgroundColor: .sunYellow.opacity(0.2)
            )
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - MSDHS Benefit View

struct MSDHSBenefitView: View {
    @ObservedObject private var viewModel = BenefitViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("การพัฒนาสังคมและความมั่นคงของมนุษย์ (พม.)")
                .font(customFont(type: .bold, textStyle: .headline))
                .padding(.top, 20)
            
            ServiceButtonView(
                title: "ระบบสวัสดิการเด็กและครอบครัว",
                imageName: "membership",
                backgroundColor: .assetsPurple,
                urlString: viewModel.urls.welfareSystem,
                viewModel: viewModel
            )
            
            ExpandingCardView(
                sfIcon: "lock.shield.fill",
                title: "กองทุนคุ้มครองเด็ก",
                contentType: .custom(AnyView(
                    DocumentListView(sections: viewModel.protectMSDHS)
                )),
                iconColor: .deepBlue,
                backgroundColor: .deepBlue.opacity(0.2)
            )
            
            ServiceButtonView(
                title: "ระบบตรวจสอบสิทธิเงินอุดหนุน\nเพื่อการเลี้ยงดูเด็กแรกเกิด",
                imageName: "stamp",
                backgroundColor: .sunYellow,
                urlString: viewModel.urls.subsidyCheck,
                viewModel: viewModel
            )
            
            ExpandingCardView(
                sfIcon: "bahtsign.circle.fill",
                title: "เงินอุดหนุนเด็กแรกเกิด",
                contentType: .custom(AnyView(
                    DocumentListView(sections: viewModel.allowanceMSDHS)
                )),
                iconColor: .assetsPurple,
                backgroundColor: .assetsPurple.opacity(0.2)
            )
            
            ExpandingCardView(
                sfIcon: "pencil",
                title: "เอกสารประกอบการลงทะเบียน",
                contentType: .custom(AnyView(
                    DocumentListView(sections: viewModel.documentMSDHS)
                )),
                iconColor: .softPink,
                backgroundColor: .softPink.opacity(0.2)
            )
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Reusable Components

/// สำหรับแสดงปุ่มบริการที่ลิงก์ไปยัง URL ภายนอก
struct ServiceButtonView: View {
    let title: String
    let imageName: String
    let backgroundColor: Color
    let urlString: String
    @ObservedObject var viewModel: BenefitViewModel
    
    var body: some View {
        Button(action: {
            viewModel.openURL(urlString)
        }, label: {
            HStack {
                Text(title)
                    .font(customFont(type: .bold, textStyle: .body))
                    .foregroundColor(.jetblack)
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 56, height: 56)
                    .foregroundColor(.jetblack)
            }
        })
        .padding()
        .frame(height: 72)
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .cornerRadius(10)
    }
}

/// สำหรับแสดงรายการเอกสารแบบแบ่งเป็นหัวข้อย่อย
struct DocumentListView: View {
    let sections: [DocumentSection]
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 16) {
            ForEach(sections.indices, id: \.self) { index in
                VStack(alignment: .leading, spacing: 8) {
                    Text(sections[index].title)
                        .font(customFont(type: .bold, textStyle: .subheadline))
                    
                    ForEach(sections[index].details, id: \.self) { detail in
                        BulletPointView(text: detail)
                    }
                }
            }
        }
    }
}

struct ExpandingCardView: View {
    @State private var isExpanded: Bool = false
    
    let sfIcon: String
    let title: String
    let contentType: ContentType
    let iconColor: Color
    let backgroundColor: Color
    
    enum ContentType {
        case text(String)
        case bulletPoints([String])
        case custom(AnyView)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 16) {
                    Image(systemName: sfIcon)
                        .font(.system(size: 24))
                        .foregroundColor(iconColor)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(backgroundColor)
                        )

                    Text(title)
                        .font(customFont(type: .bold, textStyle: .headline))
                        .foregroundColor(.jetblack)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    switch contentType {
                    case .text(let text):
                        Text(text)
                            .font(customFont(type: .regular, textStyle: .body))
                        
                    case .bulletPoints(let points):
                        ForEach(points, id: \.self) { point in
                            BulletPointView(text: point)
                        }
                        
                    case .custom(let view):
                        view
                    }
                }
                .padding()
                .transition(.move(edge: .bottom))
            }
        }
        .frame(minHeight: 72)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        .animation(.spring(), value: isExpanded)
    }
}

struct BulletPointView: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "circle.fill")
                .resizable()
                .frame(width: 6, height: 6)
                .foregroundColor(.jetblack)
                .padding(.top, 6)
            
            Text(text)
                .font(customFont(type: .regular, textStyle: .footnote))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    BenefitView()
}
