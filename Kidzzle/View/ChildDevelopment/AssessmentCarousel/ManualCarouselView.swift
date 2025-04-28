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
    
    var body: some View {
        GeometryReader { geometry in
            WebImage(url: URL(string: manual.imageURL))
                .resizable()
                .indicator(.activity)
                .transition(.fade(duration: 0.5))
                .scaledToFill()
                .frame(width: geometry.size.width, height: 128)
                .clipped()
                .background(.gray)
                .cornerRadius(10)
        }
        .frame(height: 128)
    }
}
