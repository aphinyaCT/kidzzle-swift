//
//  MotherDetailView.swift
//  Kidzzle
//
//  Created by aynnipa on 3/5/2568 BE.
//

import SwiftUI

struct MotherDetailView: View {
    let selectedPregnant: MotherPregnantData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.ivorywhite
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.jetblack)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .padding(.top, 40)
                
                // Title
                Text("ประวัติการตั้งครรภ์มารดา")
                    .font(customFont(type: .bold, textStyle: .title2))
                
                VStack (alignment: .leading, spacing: 16) {
                    HistoryLabelText(
                        title: "ชื่อ-นามสกุล (มารดา)",
                        value: selectedPregnant.motherName ?? "ไม่ระบุ",
                        sfIcon: "person.fill"
                    )
                    
                    HistoryLabelText(
                        title: "วัน/เดือน/ปีเกิด (มารดา)",
                        value: selectedPregnant.motherBirthday?.normalizeDateFormat() ?? "ไม่ระบุ",
                        sfIcon: "birthday.cake.fill"
                    )
                    
                    HistoryLabelText(
                        title: "โรคประจำตัว",
                        value: selectedPregnant.pregnantCongenitalDisease ?? "ไม่มี",
                        sfIcon: "stethoscope"
                    )
                    
                    HistoryLabelText(
                        title: "ภาวะแทรกซ้อนระหว่างตั้งครรภ์",
                        value: selectedPregnant.pregnantComplications ?? "ไม่มี",
                        sfIcon: "exclamationmark.triangle.fill"
                    )
                    
                    HistoryLabelText(
                        title: "การสูบบุหรี่หรือดื่มแอลกอฮอล์ขณะตั้งครรภ์",
                        value: selectedPregnant.pregnantDrugHistory ?? "ไม่มี",
                        sfIcon: "pills.fill"
                    )
                    
                    HistoryLabelText(
                        title: "อ้างอิง",
                        value: String(selectedPregnant.id.prefix(12)),
                        sfIcon: "person.fill.checkmark"
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
}
