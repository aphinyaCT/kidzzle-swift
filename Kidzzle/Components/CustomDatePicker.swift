//
//  CustomDatePicker.swift
//  Kidzzle
//
//  Created by aynnipa on 2/4/2568 BE.
//


import SwiftUI

struct CustomDatePicker: View {
    var title: String
    @Binding var selectedDate: Date
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "th_TH")
        formatter.calendar = Calendar(identifier: .buddhist)
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            // Selected date display - updates automatically when date changes
            Text(dateFormatter.string(from: selectedDate))
                .foregroundColor(.black)
                .padding(.horizontal)
                .frame(height: 44)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                )
                .onChange(of: selectedDate) { _, _ in
                    // This forces the view to refresh when the date changes
                    // The actual update happens automatically through the binding
                }
            
            // Always visible DatePicker
            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .environment(\.locale, Locale(identifier: "th_TH"))
                .environment(\.calendar, Calendar(identifier: .buddhist))
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }
}

// Preview
struct CustomDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.1).edgesIgnoringSafeArea(.all)
            
            VStack {
                CustomDatePicker(
                    title: "วัน/เดือน/ปีเกิด",
                    selectedDate: .constant(Date())
                )
                
                Spacer()
            }
            .padding()
        }
    }
}