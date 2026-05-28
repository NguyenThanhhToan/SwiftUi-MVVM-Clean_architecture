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
    private let clearSession: () -> Void
    private let onLogout: () -> Void

    init(clearSession: @escaping () -> Void, onLogout: @escaping () -> Void) {
        self.clearSession = clearSession
        self.onLogout = onLogout
    }

    func logout() {
        clearSession()
        onLogout()
    }
}
