//
//  EmergencyCallView.swift
//  Kidzzle
//
//  Created by aynnipa on 16/4/2568 BE.
//


import SwiftUI

struct EmergencyCallView: View {
    let emergencyContacts: [(title: String, number: String, description: String)] = [
        ("สายด่วนสุขภาพจิต", "1323", "ปรึกษาปัญหาสุขภาพจิตทั้งเด็กและผู้ปกครอง"),
        ("สายด่วน พม. ช่วยเหลือเด็ก", "1300", "ช่วยเหลือเด็กถูกทารุณกรรม / ละเมิด / เสี่ยงภัย"),
        ("สายด่วนฉุกเฉินกู้ชีพ", "1669", "เรียกรถพยาบาลกรณีฉุกเฉินต่าง ๆ"),
        ("มูลนิธิพิทักษ์สิทธิเด็ก", "02-412-0739", "ช่วยเหลือเด็กในภาวะเสี่ยง")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            ForEach(emergencyContacts, id: \.number) { contact in
                Link(destination: URL(string: "tel://\(contact.number)")!) {
                    HStack(spacing: 12) {
                        Image(systemName: "phone.bubble.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.coralRed)

                        VStack(alignment: .leading) {
                            Text(contact.title)
                                .font(customFont(type: .bold, textStyle: .body))
                                .foregroundColor(.jetblack)
                            
                            Text(contact.description)
                                .font(customFont(type: .regular, textStyle: .footnote))
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Text(contact.number)
                            .font(customFont(type: .bold, textStyle: .callout))
                            .foregroundColor(.coralRed)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 72)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
            }
        }
    }
}
