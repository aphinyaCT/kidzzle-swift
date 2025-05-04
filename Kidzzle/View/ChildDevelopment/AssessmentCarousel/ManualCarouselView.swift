//
//  ManualCarouselView.swift
//  Kidzzle
//
//  Created by aynnipa on 15/4/2568 BE.
//

import SwiftUI
import SDWebImageSwiftUI

struct ManualCarouselView: View {
    let manuals: [Manual]
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    @State private var currentIndex = 0
    
    var body: some View {
        VStack {
            TabView(selection: $currentIndex) {
                ForEach(manuals.indices, id: \.self) { index in
                    ManualCardView(manual: manuals[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 140)
            .onReceive(timer) { _ in
                withAnimation {
                    currentIndex = (currentIndex + 1) % manuals.count
                }
            }
            
            HStack(spacing: 8) {
                ForEach(manuals.indices, id: \.self) { index in
                    Circle()
                        .fill(currentIndex == index ? Color.jetblack : Color.gray.opacity(0.5))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 10)
        }
    }
}

struct ManualCardView: View {
    let manual: Manual
    @State private var showInfoPopup = false
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(manual.title)
                        .font(customFont(type: .bold, textStyle: .headline))
                        .foregroundColor(Color.jetblack)
                    
                    Text("อ่านเพิ่มเติม")
                        .font(customFont(type: .bold, textStyle: .footnote))
                        .foregroundColor(Color.jetblack)
                        .padding()
                        .frame(maxHeight: 24)
                        .background(Capsule().fill(.ivorywhite))
                }
                
                Spacer()
                
                Image(manual.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .padding()
            .background(
                ZStack {
                    Color.assetsPurple.opacity(0.2)

                    Circle()
                        .fill(Color.assetsPurple.opacity(0.5))
                        .frame(width: geometry.size.width)
                        .position(x: geometry.size.width - 16,
                                  y: geometry.size.height - 16)
                }
            )
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .onTapGesture {
                showInfoPopup = true
            }
        }
        .frame(height: 128)
        .sheet(isPresented: $showInfoPopup) {
            InfoGraphicView(manual: manual)
                .interactiveDismissDisabled()
        }
    }
}

struct InfoGraphicView: View {
    let manual: Manual
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16))
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color.white)
                            .padding(8)
                            .background(Color.jetblack)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 48)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        
                        Text(manual.title)
                            .font(customFont(type: .bold, textStyle: .title2))
                            .foregroundColor(Color.jetblack)
                        
                        Text("© กองส่งเสริมความรอบรู้และสื่อสารสุขภาพ กรมอนามัย กระทรวงสาธารณสุข")
                            .font(customFont(type: .regular, textStyle: .footnote))
                            .foregroundColor(Color.jetblack)
                        
                    }
                    
                    if let imageURL = URL(string: manual.imageURL) {
                        WebImage(url: imageURL)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    
                    if let url = URL(string: manual.linkURL) {
                        Link(destination: url) {
                            HStack (alignment: .center, spacing: 10) {
                                Image(systemName: "eye")
                                    .font(.system(size: 16))
                                
                                Text("อ่านบทความเพิ่มเติม")
                                    .font(customFont(type: .bold, textStyle: .callout))
                            }
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(Color.jetblack)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding(.bottom, 48)
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .background(Color.ivorywhite)
    }
}
