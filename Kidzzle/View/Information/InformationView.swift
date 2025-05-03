//
//  InformationView.swift
//  Kidzzle
//
//  Created by aynnipa on 17/3/2568 BE.
//

import SwiftUI
import ScalingHeaderScrollView

struct InformationView: View {
    
    @StateObject var viewModel = InformationViewModel()
    
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    @State var progress: CGFloat = 0
    
    private let minHeight = 100.0
    private let maxHeight = 150.0
    
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
                            ForEach(viewModel.information) { info in
                                InformationCardView(info: info, viewModel: viewModel)
                                    .onTapGesture {
                                        if let url = info.infoURL {
                                            print("เปิดไฟล์ PDF: \(url)")
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
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
                    Image(systemName: "book")
                        .font(.system(size: 16))
                        .frame(width: 16, height: 16)
                        .foregroundColor(Color.white)
                        .padding(8)
                        .background(Color.greenMint)
                        .cornerRadius(10)
                    
                    Text("ความรู้ทั่วไปของมารดาและบุตร")
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
                    Image(systemName: "book")
                        .font(.system(size: 24))
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color.white)
                        .padding(8)
                        .background(Color.greenMint)
                        .cornerRadius(10)
                    
                    Text("ความรู้ทั่วไปของมารดาและบุตร")
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
    
    func adaptiveColumns(for width: CGFloat) -> [GridItem] {
        let columnCount = width > 700 ? 2 :
        width > 500 ? 2 : 2
        
        return Array(repeating:
                        GridItem(.flexible(), spacing: 20),
                     count: columnCount
        )
    }
}

#Preview {
    InformationView()
}
