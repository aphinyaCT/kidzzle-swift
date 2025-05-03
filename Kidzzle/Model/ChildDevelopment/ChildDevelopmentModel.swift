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
    
    var statusText: String {
        return isPassed ? "ผ่าน" : "ไม่ผ่าน"
    }
}
