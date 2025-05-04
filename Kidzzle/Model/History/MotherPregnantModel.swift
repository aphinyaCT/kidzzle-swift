//
//  MotherPregnantModel.swift
//  Kidzzle
//
//  Created by aynnipa on 8/4/2568 BE.
//

import Foundation

struct CreateMotherPregnantRequest: Codable {
    let accessToken: String?
    let mother_birthday: String?
    let mother_name: String?
    let pregnant_complications: String?
    let pregnant_congenital_disease: String?
    let pregnant_drug_history: String?
    let userId: String?
}

struct CreateMotherPregnantResponse: Codable {
    let code: Int
    let message: String
}

struct MotherPregnantResponse: Codable {
    let data: [MotherPregnantData]

    enum CodingKeys: String, CodingKey {
        case data
    }
}

struct MotherPregnantData: Codable, Identifiable {
    let id: String
    let motherBirthday: String?
    let motherName: String?
    let pregnantComplications: String?
    let pregnantCongenitalDisease: String?
    let pregnantDrugHistory: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "pregnant_id"
        case motherBirthday = "mother_birthday"
        case motherName = "mother_name"
        case pregnantComplications = "pregnant_complications"
        case pregnantCongenitalDisease = "pregnant_congenital_disease"
        case pregnantDrugHistory = "pregnant_drug_history"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        motherBirthday = try container.decodeIfPresent(String.self, forKey: .motherBirthday)
        motherName = try container.decodeIfPresent(String.self, forKey: .motherName)
        pregnantComplications = try container.decodeIfPresent(String.self, forKey: .pregnantComplications)
        pregnantCongenitalDisease = try container.decodeIfPresent(String.self, forKey: .pregnantCongenitalDisease)
        pregnantDrugHistory = try container.decodeIfPresent(String.self, forKey: .pregnantDrugHistory)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
    }
}

struct UpdateMotherPregnantRequest: Codable {
    let pregnantId: String
    let motherBirthday: String?
    let motherName: String?
    let pregnantComplications: String?
    let pregnantCongenitalDisease: String?
    let pregnantDrugHistory: String?
}
