//
//  SettingsView.swift
//  swiftUI
//
//  Settings is intentionally lightweight for now, but it lives in its own
//  screen so future preferences, account actions, or app metadata can expand
//  here without touching the Home flow.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            // MARK: - Avatar Section
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        // Avatar circle
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                                    .padding(8)
                            )
                            .clipShape(Circle())
                        
                        Text(viewModel.userName)
                            .font(.headline)
                        
                        Text(viewModel.userEmail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)
            }
            
            Section("App") {
                row(title: "Version", value: "1.0")
                row(title: "Architecture", value: "MVVM + Clean")
            }

            Section("Account") {
                Button(role: .destructive) {
                    viewModel.logout()
                } label: {
                    Text("Logout")
                }
            }

            Section("Future") {
                Text("This tab is ready for account preferences, API settings, and logout actions.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}
