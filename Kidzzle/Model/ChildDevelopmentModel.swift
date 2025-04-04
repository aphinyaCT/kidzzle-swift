//
//  ChildDevelopmentModel.swift
//  Kidzzle
//
//  Created by aynnipa on 28/3/2568 BE.
//

import Foundation
import SwiftUI

struct AssessmentAgeRangeResponse: Codable, Identifiable {
    let ageRange: String
    let id: String
    let assessmentTypeId: String
    let maxMonths: String
    let minMonths: String
    
    enum CodingKeys: String, CodingKey {
        case ageRange = "age_range"
        case id = "age_range_id"
        case assessmentTypeId = "assessment_type_id"
        case maxMonths = "max_months"
        case minMonths = "min_months"
    }
}

struct AssessmentTrainingMethodsResponse: Codable, Identifiable {
    let assessmentNo: String
    let id: String
    let assessmentTypeId: String
    let trainingMethodsId: String
    let trainingRequiredTools: String
    let trainingText: String
    
    enum CodingKeys: String, CodingKey {
        case assessmentNo = "assessment_no"
        case id = "assessment_question_id"
        case assessmentTypeId = "assessment_type_id"
        case trainingMethodsId = "training_methods_id"
        case trainingRequiredTools = "training_required_tools"
        case trainingText = "training_text"
    }
}

struct AssessmentQuestionResponse: Codable, Identifiable {
    let ageRangeId: String
    let ageRangeName: String
    let assessmentMethod: String
    let assessmentNo: String
    let id: String
    let assessmentRequiredTool: String
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
        case id = "assessment_question_id"
        case assessmentRequiredTool = "assessment_required_tool"
        case assessmentTypeId = "assessment_type_id"
        case assessmentTypeName = "assessment_type_name"
        case devTypeId = "dev_type_id"
        case developmentType = "development_type"
        case passCriteria = "pass_criteria"
        case questionText = "question_text"
    }
}

struct AssessmentResultDataResponse: Codable, Identifiable {
    let ageRangeId: String
    let assessmentQuestionId: String
    let id: String
    let assessmentTypeId: String
    let createdAt: String
    let isPassed: String
    let kidId: String
    
    enum CodingKeys: String, CodingKey {
        case ageRangeId = "age_range_id"
        case assessmentQuestionId = "assessment_question_id"
        case id = "assessment_result_id"
        case assessmentTypeId = "assessment_type_id"
        case createdAt = "created_at"
        case isPassed = "is_passed"
        case kidId = "kid_id"
    }
}

struct AssessmentResultResponse: Codable, Identifiable {
    let assessmentQuestionId: String
    let id: String
    let createdAt: String
    let isPassed: String
    let kidId: String
    
    enum CodingKeys: String, CodingKey {
        case assessmentQuestionId = "assessment_question_id"
        case id = "assessment_result_id"
        case createdAt = "created_at"
        case isPassed = "is_passed"
        case kidId = "kid_id"
    }
}

struct Manual: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let imageURL: String
    let detail: String
    let backgroundColor: Color
}

struct ErrorResponse: Codable {
    let code: Int
    let message: String
}

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case serverError(String)
    case decodingError(Error)
    case unknownError
}
