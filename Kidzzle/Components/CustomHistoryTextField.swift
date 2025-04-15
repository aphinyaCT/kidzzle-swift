//
//  CustomHistoryTextField.swift
//  Kidzzle
//
//  Created by aynnipa on 6/4/2568 BE.
//

import SwiftUI

struct CustomHistoryTextField: View {
    
    var title: String
    var hint: String
    var sfIcon: String
    @Binding var value: String
    var isWeight: Bool = false
    var isHeight: Bool = false
    var isGestationalAge: Bool = false
    var measurementUnit: String?
    
    @State private var localValue: String = ""
    
    var body: some View {
        VStack (alignment: .leading, spacing: 16) {
            Text(title)
                .font(customFont(type: .bold, textStyle: .body))
                .foregroundColor(.jetblack)
            
            if isWeight || isHeight || isGestationalAge {
                TextField(hint, text: $localValue)
                    .font(customFont(type: .regular, textStyle: .body))
                    .textInputAutocapitalization(isWeight || isHeight || isGestationalAge ? .never : .words)
                    .keyboardType(isWeight || isHeight || isGestationalAge ? .decimalPad : .default)
                    .padding(.leading, 44)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.jetblack)
                    .background(.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.jetblack, lineWidth: 1)
                    )
                    .overlay(alignment: .leadingFirstTextBaseline) {
                        Image(systemName: sfIcon)
                            .foregroundStyle(.jetblack)
                            .frame(width: 24)
                            .padding(.horizontal, 8)
                    }
                    .overlay(alignment: .trailingLastTextBaseline) {
                        if isWeight || isHeight || isGestationalAge {
                            Text(measurementUnit ?? "ไม่มีหน่วยวัด")
                                .font(customFont(type: .regular, textStyle: .body))
                                .foregroundColor(.jetblack)
                                .padding(.trailing, 8)
                        }
                    }
                    .onChange(of: localValue) { _, newValue in
                        localValue = String(newValue.prefix(maxLength))
                        value = localValue
                    }
            } else {
                TextField(hint, text: $value)
                    .font(customFont(type: .regular, textStyle: .body))
                    .padding(.leading, 44)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.jetblack)
                    .background(.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.jetblack, lineWidth: 1)
                    )
                    .overlay(alignment: .leadingFirstTextBaseline) {
                        Image(systemName: sfIcon)
                            .foregroundStyle(.jetblack)
                            .frame(width: 24)
                            .padding(.horizontal, 8)
                    }
            }
        }
        .onAppear {
            localValue = value
        }
    }
    
    private var maxLength: Int {
        if isWeight {
            return 4
        } else if isHeight || isGestationalAge {
            return 2
        }
        return Int.max
    }
}
