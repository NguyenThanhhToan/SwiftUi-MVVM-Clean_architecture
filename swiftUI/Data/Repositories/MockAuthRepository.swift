//
//  MockAuthRepository.swift
//  swiftUI
//
//  Data layer implementations satisfy domain contracts using real services or,
//  as in this app, a deterministic mock while no API exists yet.
//

import Foundation

final class MockAuthRepository: AuthRepository {
    private let demoEmail = "demo@example.com"
    private let demoPassword = "Password123"

    func login(email: String, password: String) async throws -> User {
        try await Task.sleep(nanoseconds: 700_000_000)

        guard email.lowercased() == demoEmail.lowercased(), password == demoPassword else {
            throw AuthenticationError.invalidCredentials
        }

        return User(
            id: UUID(uuidString: "A2D0E947-4A16-4B4B-9C28-1A2A1E4D3F74") ?? UUID(),
            fullName: "Alex Johnson",
            email: demoEmail,
            role: "iOS Developer"
        )
    }
}

