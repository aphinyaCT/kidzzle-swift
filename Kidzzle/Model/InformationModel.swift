//
//  InformationModel.swift
//  Kidzzle
//
//  Created by aynnipa on 17/3/2568 BE.
//

import Foundation

struct Information: Identifiable, Codable {
    let id: String
    let title: String
    let infoURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case id, title, infoURL
    }
}
