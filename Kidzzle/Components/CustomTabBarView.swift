//
//  CustomTabBarView.swift
//  Kidzzle
//
//  Created by aynnipa on 29/3/2568 BE.
//

import SwiftUI

struct CustomTabBarView: View {
    
    @Binding var selectedIndex: Int
    
    let icons = [
        "bookmark",
        "text.page.badge.magnifyingglass",
        "bolt.heart",
        "cross.case",
        "book",
    ]
    
    let labels = [
        "บันทึกประวัติ",
        "ประเมิน",
        "ส่งเสริม",
        "สวัสดิการ",
        "ความรู้ทั่วไป"
    ]
    
    var body: some View {
        HStack {
            Spacer()
            
            ForEach(0..<icons.count, id: \.self) { number in
                Button(action: {
                    self.selectedIndex = number
                }) {
                    VStack(alignment: .center, spacing: 8) {
                        Image(systemName: icons[number])
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(selectedIndex == number ? .black : .gray)
                        
                        Text(labels[number])
                            .font(Font.custom("NotoSansThai-Bold", size: 12))
                            .foregroundColor(selectedIndex == number ? .black : .gray)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .background(.white)
    }
}

#Preview {
    CustomTabBarView(selectedIndex: .constant(2))
}
