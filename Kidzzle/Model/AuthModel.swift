//
//  AuthModel.swift
//  Kidzzle
//
//  Created by aynnipa on 1/3/2568 BE.
//

import Foundation

struct User: Identifiable, Codable {
    var id: String
    var email: String
    var password: String
    
    enum CodingKeys: String, CodingKey {
        case id = "userId"
        case email
        case password
    }
}

struct SocialAuthResponse: Codable {
    let code: Int
    let message: String
    let access_token: String?
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterResponse: Codable {
    let code: Int
    let message: String?
}

struct LoginResponse: Codable {
    let code: Int
    let message: String?
    let access_token: String?
}

struct SocialLoginRequest: Codable {
    let email: String
    let method: String
    let token: String
}

struct TokenVerificationData: Codable {
    let accessToken: String
    let userId: String
}

struct RequestResetPasswordRequest: Codable {
    let email: String
}

struct ResetPasswordRequest: Codable {
    let password: String
    let token: String
}

struct RequestResetPasswordResponse: Codable {
    let code: Int
    let token: String
}

struct ResetPasswordResponse: Codable {
    let code: Int
    let message: String
}
