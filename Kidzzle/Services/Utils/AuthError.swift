//
//  AuthError.swift
//  Kidzzle
//
//  Created by aynnipa on 23/3/2568 BE.
//

import Foundation

enum AuthError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case serverError(String)
}
