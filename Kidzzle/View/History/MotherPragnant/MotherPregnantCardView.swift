//
//  MotherPregnantCardView.swift
//  Kidzzle
//
//  Created by aynnipa on 3/5/2568 BE.
//

import SwiftUI

struct MotherPregnantCardView: View {
    let pregnant: MotherPregnantData
    let viewModel: MotherPregnantViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("มารดาและบุตร")
                        .font(customFont(type: .medium, textStyle: .caption1))
                        .padding(4)
                        .padding(.horizontal, 8)
                        .background(Color.sunYellow)
                        .cornerRadius(10)
                    
                    Text(pregnant.motherName ?? "ไม่ทราบชื่อ")
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
            
            Spacer()
            
            HStack {
                Image(systemName: "birthday.cake.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.jetblack)
                
                Text(AgeHelper.formatAge(from: pregnant.motherBirthday))
                    .font(customFont(type: .regular, textStyle: .footnote))
                    .lineLimit(2)
            }
            
            HStack {
                HStack {
                    Image(systemName: "person.fill.checkmark")
                        .font(.system(size: 16))
                        .foregroundColor(.jetblack)
                    
                    Text("\(pregnant.id.prefix(12))")
                        .font(customFont(type: .regular, textStyle: .footnote))
                }
                
                Spacer()
                
                HStack {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 16))
                        .foregroundColor(.jetblack)
                    
                    Text("สร้างเมื่อ: \(pregnant.createdAt?.normalizeDateFormat() ?? "ไม่พบวันที่สร้าง")")
                        .font(customFont(type: .regular, textStyle: .footnote))
                }
                
                Spacer()
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
