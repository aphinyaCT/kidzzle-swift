//
//  KidCardView.swift
//  Kidzzle
//
//  Created by aynnipa on 3/5/2568 BE.
//

import SwiftUI

struct KidCardView: View {
    let kid: KidHistoryData
    let viewModel: KidHistoryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("บุตร")
                        .font(customFont(type: .medium, textStyle: .caption1))
                        .padding(4)
                        .padding(.horizontal, 8)
                        .background(Color.sunYellow)
                        .cornerRadius(10)
                    
                    Text(kid.kidName ?? "ไม่ทราบชื่อ")
                        .font(customFont(type: .bold, textStyle: .body))
                        .lineLimit(1)
                        .foregroundColor(.jetblack)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.forward")
                    .font(.system(size: 24))
                    .foregroundColor(.jetblack)
                    .padding()
                    .frame(width: 40, height: 40)
                    .background(Color.sunYellow)
                    .cornerRadius(10)
            }
            
            HStack {
                Image(systemName: "birthday.cake.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.jetblack)
                
                Text(AgeHelper.formatAge(from: kid.kidBirthday))
                    .font(customFont(type: .regular, textStyle: .footnote))
            }
            
            HStack (spacing: 24) {
                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 16))
                        .foregroundColor(.jetblack)
                    
                    let gestationalResult = viewModel.evaluateGestationalDeliveryStatus(kid.kidGestationalAge ?? "ไม่ระบุ")
                    Text(gestationalResult.status)
                        .font(customFont(type: .regular, textStyle: .footnote))
                        .foregroundColor(gestationalResult.color)
                }
                
                HStack {
                    Image(systemName: "scalemass.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.jetblack)
                    
                    let weightResult = viewModel.evaluateBirthWeightStatus(weightString: kid.kidBirthWeight ?? "ไม่ระบุ")
                    Text(weightResult.status)
                        .font(customFont(type: .regular, textStyle: .footnote))
                        .foregroundColor(weightResult.color)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.sunYellow, lineWidth: 1)
        )
    }
}
