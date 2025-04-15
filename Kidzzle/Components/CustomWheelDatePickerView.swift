//
//  CustomWheelDatePickerView.swift
//  Kidzzle
//
//  Created by aynnipa on 6/4/2568 BE.
//

import SwiftUI

struct CustomWheelDatePickerView: View {
    @Binding var selectedDate: Date
    let title: String
    
    @Environment(\.calendar) private var calendar
    
    init(selectedDate: Binding<Date>, title: String) {
        self._selectedDate = selectedDate
        self.title = title
        
        // ตั้งค่า UIDatePicker เป็น Gregorian และ en_US
        UIDatePicker.appearance().calendar = Calendar(identifier: .gregorian)
        UIDatePicker.appearance().locale = Locale(identifier: "en_US")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(customFont(type: .bold, textStyle: .body))
                .foregroundColor(.jetblack)
            
            DatePicker("", selection: $selectedDate,
                       in: ...Date(),
                       displayedComponents: .date)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.jetblack, lineWidth: 1)
                )
                // กำหนดให้ใช้ปฏิทิน Gregorian และ locale เป็นภาษาอังกฤษเสมอ
                .environment(\.calendar, Calendar(identifier: .gregorian))
                .environment(\.locale, Locale(identifier: "en_US"))
        }
        .onAppear {
            // แปลงวันที่เป็น Gregorian เสมอ
            var gregorianCalendar = Calendar(identifier: .gregorian)
            gregorianCalendar.timeZone = TimeZone(abbreviation: "ICT") ?? .current
            
            let components = gregorianCalendar.dateComponents([.year, .month, .day], from: selectedDate)
            
            if let gregorianDate = gregorianCalendar.date(from: components) {
                DispatchQueue.main.async {
                    selectedDate = gregorianDate
                }
            }
        }
    }
}
