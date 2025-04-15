//
//  CustomDropdownPickerView.swift
//  Kidzzle
//
//  Created by aynnipa on 6/4/2568 BE.
//

import SwiftUI

struct CustomDropdownPickerView: View {
    @Binding var selectedOption: String
    let options: [String]
    let title: String
    let sfIcon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(customFont(type: .bold, textStyle: .body))
                .foregroundColor(.jetblack)
            
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selectedOption = option
                    }) {
                        Text(option)
                            .font(customFont(type: .regular, textStyle: .body))
                            .foregroundColor(.jetblack)
                    }
                }
            } label: {
                HStack {
                    Image(systemName: sfIcon)
                        .foregroundColor(.jetblack)
                        .frame(width: 24)
                    
                    Text(selectedOption.isEmpty ? "โปรดระบุ" : selectedOption)
                        .font(customFont(type: .regular, textStyle: .body))
                        .foregroundColor(.jetblack)
                        .padding(.leading, 4)
                    
                    Spacer()
                }
                .padding(.leading, 10)
                .frame(height: 44)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.jetblack, lineWidth: 1)
                )
            }
        }
    }
}
