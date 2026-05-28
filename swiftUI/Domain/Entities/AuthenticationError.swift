//
//  AuthenticationError.swift
//  swiftUI
//
//  Domain-level errors describe business rules. The presentation layer can
//  turn them into user-facing messages.
//

import Foundation

enum AuthenticationError: LocalizedError, Equatable {
    case invalidCredentials
    case invalidEmailFormat
    case invalidPassword

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "The email or password is incorrect."
        case .invalidEmailFormat:
            return "Please enter a valid email address."
        case .invalidPassword:
            return "Password must be at least 8 characters long."
        }
    }
}
