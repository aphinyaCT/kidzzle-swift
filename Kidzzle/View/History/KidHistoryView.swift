//
//  KidHistoryView.swift
//  Kidzzle
//
//  Created by aynnipa on 2/4/2568 BE.
//

import SwiftUI
import ScalingHeaderScrollView

struct KidHistoryView: View {
    @State private var progress: CGFloat = 0
    
        private let minHeight = 100.0
        private let maxHeight = 200.0
    
    @State private var isEditing: Bool = false
    
    var body: some View {
        ZStack {
            ScalingHeaderScrollView {
                largeHeader(progress: progress)
            } content: {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 20)
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
                    Image(systemName: "arrow.backward")
                        .font(.system(size: 16))
                        .frame(width: 16, height: 16)
                        .foregroundColor(Color.jetblack)
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    Spacer()
                    
                    Button(action: {
                        
                    }, label: {
                        Text("บันทึก")
                            .font(customFont(type: .bold, textStyle: .body))
                            .foregroundColor(Color.jetblack)
                    })
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 48)
            
            Spacer()
        }
        .ignoresSafeArea(.container, edges: [.top, .horizontal])
    }
    
    private func largeHeader(progress: CGFloat) -> some View {
        VStack(spacing: 0) {
            ZStack {
                VStack (alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "arrow.backward")
                            .font(.system(size: 24))
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color.jetblack)
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                        Spacer()
                        
                        Button(action: {
                            
                        }, label: {
                            Text("บันทึก")
                                .font(customFont(type: .bold, textStyle: .body))
                                .foregroundColor(Color.jetblack)
                        })
                    }
                    .padding(.bottom, 20)
                    
                    Text(isEditing == false ? "เพิ่มประวัติลูกน้อย" : "แก้ไขประวัติลูกน้อย")
                        .font(customFont(type: .bold, textStyle: .title2))
                        .foregroundColor(Color.jetblack)
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

#Preview {
    KidHistoryView()
}
