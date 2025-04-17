//
//  TabSelectorView.swift
//  Kidzzle
//
//  Created by aynnipa on 14/4/2568 BE.
//

import SwiftUI

struct TabSelectorView: View {
    @Binding var selectedTab: QuestionTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(QuestionTab.allCases, id: \.self) { tab in
                TabButton(
                    sfIcon: tab.icon,
                    title: tab.rawValue,
                    isSelected: selectedTab == tab,
                    action: { selectedTab = tab }
                )
            }
        }
        .background(Color(white: 0.95))
        .cornerRadius(10)
    }
}

struct TabButton: View {
    let sfIcon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: sfIcon)
                    .font(.system(size: 16))

                Text(title)
                    .font(customFont(type: isSelected ? .bold : .regular, textStyle: .callout))
            }
            .foregroundColor(isSelected ? .white : .jetblack)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(isSelected ? Color.jetblack : Color.clear)
            .cornerRadius(10)
        }
    }
}

enum QuestionTab: String, CaseIterable {
    case questions = "คำถามประเมิน"
    case summary = "สรุปผลการประเมิน"
    
    var icon: String {
        switch self {
        case .questions:
            return "checklist"
        case .summary:
            return "chart.xyaxis.line"
        }
    }
}
