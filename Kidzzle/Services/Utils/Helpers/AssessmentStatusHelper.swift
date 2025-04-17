//
//  AssessmentStatusHelper.swift
//  Kidzzle
//
//  Created by aynnipa on 14/4/2568 BE.
//

import Foundation
import SwiftUI

struct AssessmentStatusHelper {
    static func getStatusIcon(isAssessed: Bool, isPassed: Bool) -> String {
        if isAssessed {
            return isPassed ? "checkmark" : "arrow.clockwise"
        } else {
            return "questionmark"
        }
    }
    
    static func getStatusBackgroundColor(isAssessed: Bool, isPassed: Bool) -> Color {
        if isAssessed {
            return isPassed ? Color.green.opacity(0.2) : Color.orange.opacity(0.2)
        } else {
            return Color.gray.opacity(0.2)
        }
    }
    
    static func getStatusIconColor(isAssessed: Bool, isPassed: Bool) -> Color {
        if isAssessed {
            return isPassed ? Color.green : Color.orange
        } else {
            return Color.gray
        }
    }
}
