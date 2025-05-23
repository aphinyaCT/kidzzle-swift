//
//  KidHistoryModel.swift
//  Kidzzle
//
//  Created by aynnipa on 7/4/2568 BE.
//

import Foundation

struct CreateKidHistoryRequest: Codable {
    let accessToken: String?
    let kid_birth_weight: String?
    let kid_birthday: String?
    let kid_blood_type: String?
    let kid_body_length: String?
    let kid_congenital_disease: String?
    let kid_gender: String?
    let kid_gestational_age: String?
    let kid_name: String?
    let kid_oxygen: String?
    let pregnantId: String?
    let userId: String?
}

struct CreateKidHistoryResponse: Codable {
    let code: Int
    let message: String
}

struct KidHistoryResponse: Codable {
    let data: [KidHistoryData]
    
    enum CodingKeys: String, CodingKey {
        case data
    }
}

struct KidHistoryData: Codable, Identifiable {
    let id: String
    let kidName: String?
    let kidBirthday: String?
    let kidGender: String?
    let kidBirthWeight: String?
    let kidBodyLength: String?
    let kidBloodType: String?
    let kidCongenitalDisease: String?
    let kidOxygen: String?
    let kidGestationalAge: String?
    let pregnantId: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "kid_id"
        case kidName = "kid_name"
        case kidBirthday = "kid_birthday"
        case kidGender = "kid_gender"
        case kidBirthWeight = "kid_birth_weight"
        case kidBodyLength = "kid_body_length"
        case kidBloodType = "kid_blood_type"
        case kidCongenitalDisease = "kid_congenital_disease"
        case kidOxygen = "kid_oxygen"
        case kidGestationalAge = "kid_gestational_age"
        case pregnantId = "pregnant_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        kidName = try container.decodeIfPresent(String.self, forKey: .kidName)
        kidBirthday = try container.decodeIfPresent(String.self, forKey: .kidBirthday)
        kidGender = try container.decodeIfPresent(String.self, forKey: .kidGender)
        kidBirthWeight = try container.decodeIfPresent(String.self, forKey: .kidBirthWeight)
        kidBodyLength = try container.decodeIfPresent(String.self, forKey: .kidBodyLength)
        kidBloodType = try container.decodeIfPresent(String.self, forKey: .kidBloodType)
        kidCongenitalDisease = try container.decodeIfPresent(String.self, forKey: .kidCongenitalDisease)
        kidOxygen = try container.decodeIfPresent(String.self, forKey: .kidOxygen)
        kidGestationalAge = try container.decodeIfPresent(String.self, forKey: .kidGestationalAge)
        pregnantId = try container.decodeIfPresent(String.self, forKey: .pregnantId)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
    }
}

struct UpdateKidHistoryRequest: Codable {
    let userId: String
    let kidId: String 
    let kid_birth_weight: String?
    let kid_birthday: String?
    let kid_blood_type: String?
    let kid_body_length: String?
    let kid_congenital_disease: String?
    let kid_gender: String?
    let kid_gestational_age: String?
    let kid_name: String?
    let kid_oxygen: String?
    let pregnantId: String?
}
