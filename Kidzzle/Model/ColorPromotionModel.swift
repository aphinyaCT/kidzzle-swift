//
//  ColorPromotionModel.swift
//  Kidzzle
//
//  Created by aynnipa on 12/3/2568 BE.
//

import Foundation

struct PromotionColor: Identifiable, Codable {
    let id: String
    let name: String
    let shape: String
    let audioURL: URL?
    let imageURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case id = "color_id"
        case name = "color_name"
        case shape = "color_shape"
        case audioURL = "color_sound_file_url"
        case imageURL = "color_image_url"
    }
}
