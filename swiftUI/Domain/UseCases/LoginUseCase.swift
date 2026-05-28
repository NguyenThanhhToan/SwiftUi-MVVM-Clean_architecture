//
//  LoginUseCase.swift
//  swiftUI
//
//  Use cases encode application-specific behavior. This one validates the
//  input and delegates authentication to the repository.
//

import Foundation

struct LoginUseCase {
    let authRepository: AuthRepository

    func execute(email: String, password: String) async throws -> User {
        let normalizedEmail = email.trimmed
        let normalizedPassword = password.trimmed

        guard normalizedEmail.isValidEmail else {
            throw AuthenticationError.invalidEmailFormat
        }

        guard normalizedPassword.isValidPassword else {
            throw AuthenticationError.invalidPassword
        }

        return try await authRepository.login(email: normalizedEmail, password: normalizedPassword)
    }
}

