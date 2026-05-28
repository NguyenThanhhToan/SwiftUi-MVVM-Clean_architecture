//
//  LoginViewModel.swift
//  swiftUI
//
//  View models adapt use cases for SwiftUI. They hold screen state and expose
//  actions that the view can trigger.
//

import Combine
import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var emailErrorMessage: String?
    @Published var passwordErrorMessage: String?
    @Published var generalErrorMessage: String?

    private let loginUseCase: LoginUseCase

    init(loginUseCase: LoginUseCase) {
        self.loginUseCase = loginUseCase
    }

    func login() async -> User? {
        clearErrors()
        guard validateInputs() else { return nil }

        isLoading = true
        defer { isLoading = false }

        do {
            return try await loginUseCase.execute(email: email, password: password)
        } catch let error as AuthenticationError {
            generalErrorMessage = error.localizedDescription
            return nil
        } catch {
            generalErrorMessage = "Something went wrong. Please try again."
            return nil
        }
    }

    private func validateInputs() -> Bool {
        var isValid = true

        if !email.trimmed.isValidEmail {
            emailErrorMessage = AuthenticationError.invalidEmailFormat.localizedDescription
            isValid = false
        }

        if !password.trimmed.isValidPassword {
            passwordErrorMessage = AuthenticationError.invalidPassword.localizedDescription
            isValid = false
        }

        return isValid
    }

    private func clearErrors() {
        emailErrorMessage = nil
        passwordErrorMessage = nil
        generalErrorMessage = nil
    }
}
