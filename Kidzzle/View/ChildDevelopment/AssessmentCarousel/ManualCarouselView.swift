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
            let isLargeScreen = geometry.size.width > 700
            
            HStack(alignment: .center, spacing: 16) {
                WebImage(url: URL(string: manual.imageURL))
                    .resizable()
                    .indicator(.activity)
                    .transition(.fade(duration: 0.5))
                    .scaledToFit()
                    .frame(height: isLargeScreen ? 120 : 96)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(manual.title)
                        .font(customFont(type: .bold, textStyle: isLargeScreen ? .subheadline : .footnote))
                        .lineLimit(isLargeScreen ? 1 : 2, reservesSpace: isLargeScreen ? false : true)
                    
                    Text(manual.subtitle)
                        .font(customFont(type: isLargeScreen ? .bold : .medium, textStyle: .footnote))
                        .lineLimit(isLargeScreen ? 1 : 3, reservesSpace: isLargeScreen ? false : true)
                    
                    if isLargeScreen {
                        Text(manual.detail)
                            .font(customFont(type: .regular, textStyle: .footnote))
                            .lineLimit(isLargeScreen ? 2 : 0, reservesSpace: isLargeScreen ? false : true)
                            .padding(.top, 16)
                    }
                }
                .foregroundColor(Color.white)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding()
            .background(manual.backgroundColor)
            .frame(width: geometry.size.width)
            .frame(height: 128)
            .cornerRadius(10)
        }
        .frame(height: 128)
    }
}
