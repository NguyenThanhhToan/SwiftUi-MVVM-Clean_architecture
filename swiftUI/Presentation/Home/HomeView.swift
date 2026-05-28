//
//  HomeView.swift
//  swiftUI
//
//  This screen presents authenticated user data and the province list.
//  Province taps are handled in the view model for logging and then forwarded
//  to the parent navigation shell, which pushes the district screen.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    let onProvinceSelected: (Province) -> Void

    init(viewModel: HomeViewModel, onProvinceSelected: @escaping (Province) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onProvinceSelected = onProvinceSelected
    }

    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Header

            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.welcomeMessage)
                    .font(.largeTitle.bold())

                Text("You are now signed in.")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // MARK: - User Info

            VStack(spacing: 16) {
                userInfoRow(title: "Full Name", value: viewModel.user.fullName)
                userInfoRow(title: "Email", value: viewModel.user.email)
                userInfoRow(title: "Role", value: viewModel.user.role)
            }
            .padding()
            .background(Color.green.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // MARK: - Province List

            VStack(alignment: .leading, spacing: 12) {
                Text("Vietnamese Provinces")
                    .font(.headline)

                if viewModel.isLoadingProvinces {
                    ProgressView("Loading provinces...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.provinces) { province in
                                Button {
                                    viewModel.selectProvince(province)
                                    onProvinceSelected(province)
                                } label: {
                                    provinceRow(province)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .frame(maxHeight: 300)
                }
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color.green.opacity(0.12),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .task {
            await viewModel.loadProvinces()
        }
    }

    private func provinceRow(_ province: Province) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(province.provinceName)
                    .font(.headline)

                Text("Province ID: \(province.provinceID)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func userInfoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)

            Spacer()

            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}
