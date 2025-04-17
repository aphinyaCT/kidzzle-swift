//
//  DevelopmentTypeHelper.swift
//  Kidzzle
//
//  Created by aynnipa on 14/4/2568 BE.
//

import Foundation
import SwiftUI

enum DevelopmentTypeHelper {
    static func getFullName(_ type: String) -> String {
        switch type {
        case "GM":
            return "พัฒนาการด้านการเคลื่อนไหว (GM)"
        case "FM":
            return "พัฒนาการด้านกล้ามเนื้อมัดเล็กและสติปัญญา (FM)"
        case "RL":
            return "พัฒนาการด้านการเข้าใจภาษา (RL)"
        case "EL":
            return "พัฒนาการด้านการใช้ภาษา (EL)"
        case "PS":
            return "พัฒนาการด้านการช่วยเหลือตัวเองและสังคม (PS)"
        default:
            return type
        }
    }
    
    static func getColor(_ type: String) -> Color {
        switch type {
        case "GM":
            return .deepBlue
        case "FM":
            return .assetsPurple
        case "RL":
            return .softPink
        case "EL":
            return .sunYellow
        case "PS":
            return .coralRed
        default:
            return .gray
        }
    }
}
