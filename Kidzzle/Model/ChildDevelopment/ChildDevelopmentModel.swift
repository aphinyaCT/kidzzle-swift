//
//  ChildDevelopmentModel.swift
//  Kidzzle
//
//  Created by aynnipa on 28/3/2568 BE.
//

import Foundation
import SwiftUI
import Combine

struct CreateAssessmentRequest: Codable {
    let accessToken: String?
    let assessment_question_id: String?
    let is_passed: Bool?
    let kid_id: String?
}

struct CreateAssessmentResponse: Codable {
    let code: Int
    let message: String
}

struct AgeRangeData: Codable {
    let ageRange: String
    let ageRangeId: String
    let assessmentTypeId: String
    let maxMonths: String?
    let minMonths: String?
    let assessmentVdoUrl: String?

    enum CodingKeys: String, CodingKey {
        case ageRange = "age_range"
        case ageRangeId = "age_range_id"
        case assessmentTypeId = "assessment_type_id"
        case maxMonths = "max_months"
        case minMonths = "min_months"
        case assessmentVdoUrl = "assessment_video_url"
    }
}

struct AssessmentQuestionData: Codable {
    let ageRangeId: String
    let ageRangeName: String
    let assessmentMethod: String
    let assessmentNo: String
    let assessmentQuestionId: String
    let assessmentRequiredTool: String?
    let assessmentTypeId: String
    let assessmentTypeName: String
    let devTypeId: String
    let developmentType: String
    let passCriteria: String
    let questionText: String

    enum CodingKeys: String, CodingKey {
        case ageRangeId = "age_range_id"
        case ageRangeName = "age_range_name"
        case assessmentMethod = "assessment_method"
        case assessmentNo = "assessment_no"
        case assessmentQuestionId = "assessment_question_id"
        case assessmentRequiredTool = "assessment_required_tool"
        case assessmentTypeId = "assessment_type_id"
        case assessmentTypeName = "assessment_type_name"
        case devTypeId = "dev_type_id"
        case developmentType = "development_type"
        case passCriteria = "pass_criteria"
        case questionText = "question_text"
    }

    init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            ageRangeId = try container.decode(String.self, forKey: .ageRangeId).trimmingCharacters(in: .whitespacesAndNewlines)
            ageRangeName = try container.decode(String.self, forKey: .ageRangeName)
            assessmentMethod = try container.decode(String.self, forKey: .assessmentMethod)
            assessmentNo = try container.decode(String.self, forKey: .assessmentNo)
            assessmentQuestionId = try container.decode(String.self, forKey: .assessmentQuestionId)

            assessmentRequiredTool = try container.decodeIfPresent(String.self, forKey: .assessmentRequiredTool)
            
            assessmentTypeId = try container.decode(String.self, forKey: .assessmentTypeId)
            assessmentTypeName = try container.decode(String.self, forKey: .assessmentTypeName)
            devTypeId = try container.decode(String.self, forKey: .devTypeId)
            developmentType = try container.decode(String.self, forKey: .developmentType)
            passCriteria = try container.decode(String.self, forKey: .passCriteria)
            questionText = try container.decode(String.self, forKey: .questionText)
            
        } catch {
            print("❌ Error decoding AssessmentQuestionData: \(error)")
            throw error
        }
    }

    init(ageRangeId: String, ageRangeName: String, assessmentMethod: String, assessmentNo: String,
         assessmentQuestionId: String, assessmentRequiredTool: String?, assessmentTypeId: String,
         assessmentTypeName: String, devTypeId: String, developmentType: String,
         passCriteria: String, questionText: String) {
        
        self.ageRangeId = ageRangeId
        self.ageRangeName = ageRangeName
        self.assessmentMethod = assessmentMethod
        self.assessmentNo = assessmentNo
        self.assessmentQuestionId = assessmentQuestionId
        self.assessmentRequiredTool = assessmentRequiredTool
        self.assessmentTypeId = assessmentTypeId
        self.assessmentTypeName = assessmentTypeName
        self.devTypeId = devTypeId
        self.developmentType = developmentType
        self.passCriteria = passCriteria
        self.questionText = questionText
    }
}

struct DevelopmentTrainingData: Codable {
    let trainingMethodsId: String
    let assessmentQuestionId: String
    let assessmentTypeId: String
    let assessmentNo: String
    let trainingText: String
    let trainingRequiredTools: String?
    
    enum CodingKeys: String, CodingKey {
        case trainingMethodsId = "training_methods_id"
        case assessmentQuestionId = "assessment_question_id"
        case assessmentTypeId = "assessment_type_id"
        case assessmentNo = "assessment_no"
        case trainingText = "training_text"
        case trainingRequiredTools = "training_required_tools"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        trainingMethodsId = try container.decode(String.self, forKey: .trainingMethodsId)
        assessmentQuestionId = try container.decode(String.self, forKey: .assessmentQuestionId)
        assessmentTypeId = try container.decode(String.self, forKey: .assessmentTypeId)
        assessmentNo = try container.decode(String.self, forKey: .assessmentNo)
        trainingText = try container.decode(String.self, forKey: .trainingText)
        trainingRequiredTools = try container.decodeIfPresent(String.self, forKey: .trainingRequiredTools)
    }
}

struct AssessmentResult: Codable, Identifiable {
    let id: String
    let ageRangeId: String
    let assessmentQuestionId: String
    let assessmentTypeId: String
    let createdAt: Date
    let isPassed: Bool
    let kidId: String
    
    enum CodingKeys: String, CodingKey {
        case id = "assessment_result_id"
        case ageRangeId = "age_range_id"
        case assessmentQuestionId = "assessment_question_id"
        case assessmentTypeId = "assessment_type_id"
        case createdAt = "created_at"
        case isPassed = "is_passed"
        case kidId = "kid_id"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        ageRangeId = try container.decode(String.self, forKey: .ageRangeId)
        assessmentQuestionId = try container.decode(String.self, forKey: .assessmentQuestionId)
        assessmentTypeId = try container.decode(String.self, forKey: .assessmentTypeId)
        
        let dateString = try container.decode(String.self, forKey: .createdAt)
        let dateFormatter = ISO8601DateFormatter()
        if let date = dateFormatter.date(from: dateString) {
            createdAt = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .createdAt, in: container, debugDescription: "Invalid date format")
        }
        
        isPassed = try container.decode(Bool.self, forKey: .isPassed)
        kidId = try container.decode(String.self, forKey: .kidId)
    }
    
    var statusText: String {
        return isPassed ? "ผ่าน" : "ไม่ผ่าน"
    }
}
