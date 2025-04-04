//
//  BodyPartPromotionModel.swift
//  Kidzzle
//
//  Created by aynnipa on 13/3/2568 BE.
//

import Foundation

struct PromotionBodyPart: Identifiable, Codable {
    let id: String
    let name: String
    let audioURL: URL?
    let imageURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case id = "body_id"
        case name = "body_name"
        case audioURL = "body_sound_file_url"
        case imageURL = "body_image_url"
    }
}
