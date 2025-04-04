//
//  CustomHeaderView.swift
//  Kidzzle
//
//  Created by aynnipa on 21/2/2568 BE.
//

import SwiftUI

struct CustomHeaderView: View {
    var onNotificationTap: () -> Void
    var onLogoutTap: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image("KIDZZLE-LOGO")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 48)
            
            Spacer()
            
            Button(action: onNotificationTap) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.jetblack)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(.gray.opacity(0.3)))
            }
            
            Button(action: onLogoutTap) {
                Image(systemName: "rectangle.portrait.and.arrow.forward.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.jetblack)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(.gray.opacity(0.3)))
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    CustomHeaderView(
        onNotificationTap: { print("แจ้งเตือนถูกกด") },
        onLogoutTap: { print("ออกจากระบบ") }
    )
}
