//
//  AppRootView.swift
//  swiftUI
//
//  Presentation is responsible for navigation and screen composition.
//  The authenticated shell uses a TabView so Home, Notes, and Settings can
//  grow independently without changing the login flow.
//

import SwiftUI

struct AppRootView: View {
    private let container: AppContainer
    @State private var homePath: [Province] = []

    init(container: AppContainer) {
        self.container = container
    }

    var body: some View {
        Group {
            if let authenticatedUser = container.makeAuthSessionStore().currentUser {
                authenticatedShell(for: authenticatedUser)
            } else {
                LoginView(
                    viewModel: container.makeLoginViewModel()
                ) { user in
                    container.saveLoggedInState(user: user)
                }
            }
        }
    }

    @ViewBuilder
    private func authenticatedShell(for user: User) -> some View {
        let logoutAction = {
            container.clearLoggedInState()
            homePath.removeAll()
        }

        TabView {
            NavigationStack(path: $homePath) {
                HomeView(viewModel: container.makeHomeViewModel(user: user)) { province in
                    homePath.append(province)
                }
                .navigationDestination(for: Province.self) { province in
                    DistrictView(viewModel: container.makeDistrictViewModel(province: province))
                }
            }
            .tabItem {
                Label(AppTab.home.title, systemImage: AppTab.home.systemImage)
            }
            .tag(AppTab.home)

            NavigationStack {
                NotesView(viewModel: container.makeNotesViewModel())
            }
            .tabItem {
                Label(AppTab.notes.title, systemImage: AppTab.notes.systemImage)
            }
            .tag(AppTab.notes)

            NavigationStack {
                SettingsView(viewModel: container.makeSettingsViewModel(onLogout: logoutAction))
            }
            .tabItem {
                Label(AppTab.settings.title, systemImage: AppTab.settings.systemImage)
            }
            .tag(AppTab.settings)
        }
    }
}
