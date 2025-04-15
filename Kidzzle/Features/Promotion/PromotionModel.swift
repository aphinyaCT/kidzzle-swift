//
//  PromotionModel.swift
//  Kidzzle
//
//  Created by aynnipa on 18/3/2568 BE.
//

import Foundation

struct Promotion: Identifiable, Codable {
    let id: String
    let title: String
    let textWarning: String
    let sfIcon: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, textWarning, sfIcon
    }
}
