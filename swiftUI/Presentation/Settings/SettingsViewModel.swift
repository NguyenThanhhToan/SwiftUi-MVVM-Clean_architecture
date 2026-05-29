//
//  SettingsViewModel.swift
//  swiftUI
//
//  Settings owns the logout action, but the actual session mutation stays in
//  Core so the presentation layer does not know where auth state is stored.
//

import Combine
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    let userName: String
    let userEmail: String
    private let clearSession: () -> Void
    private let onLogout: () -> Void

    init(user: User, clearSession: @escaping () -> Void, onLogout: @escaping () -> Void) {
        self.userName = user.fullName
        self.userEmail = user.email
        self.clearSession = clearSession
        self.onLogout = onLogout
    }

    func logout() {
        clearSession()
        onLogout()
    }
}
