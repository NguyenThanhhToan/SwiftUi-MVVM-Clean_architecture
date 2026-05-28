//
//  AuthRepository.swift
//  swiftUI
//
//  Repository protocols live in the domain layer so the rest of the app can
//  depend on abstractions instead of concrete data sources.
//

import Foundation

protocol AuthRepository {
    func login(email: String, password: String) async throws -> User
}

