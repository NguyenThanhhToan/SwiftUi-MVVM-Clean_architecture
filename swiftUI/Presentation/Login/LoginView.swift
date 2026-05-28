//
//  LoginView.swift
//  swiftUI
//
//  The login screen stays thin: it renders state from the view model and
//  forwards user intent back into the presentation layer.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    let onLoginSuccess: (User) -> Void

    init(viewModel: LoginViewModel, onLoginSuccess: @escaping (User) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onLoginSuccess = onLoginSuccess
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer(minLength: 24)

            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome Back")
                    .font(.largeTitle.bold())
                Text("Use the demo credentials to continue.")
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 14) {
                TextField("Email", text: $viewModel.email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(.roundedBorder)

                if let emailErrorMessage = viewModel.emailErrorMessage {
                    validationLabel(emailErrorMessage)
                }

                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)

                if let passwordErrorMessage = viewModel.passwordErrorMessage {
                    validationLabel(passwordErrorMessage)
                }
            }

            if let generalErrorMessage = viewModel.generalErrorMessage {
                Text(generalErrorMessage)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
            }

            Button {
                Task {
                    if let user = await viewModel.login() {
                        onLoginSuccess(user)
                    }
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
            .padding(.top, 8)

            Spacer()

            demoCredentialsCard
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.12), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }

    private var demoCredentialsCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Demo Credentials")
                .font(.headline)
            Text("Email: demo@example.com")
            Text("Password: Password123")
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func validationLabel(_ message: String) -> some View {
        Text(message)
            .font(.caption)
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

