//
//  HomeView.swift
//  swiftUI
//
//  This screen acts as the location picker landing page for Local Life AI.
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
        VStack(spacing: 18) {
            
            headerSection
            
            contextSection
            
            provinceListSection
                .frame(maxHeight: .infinity)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(backgroundView)
        .task {
            await viewModel.loadProvinces()
        }
    }
}

private extension HomeView {
    var headerSection: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .frame(width: 56, height: 56)

                Image(systemName: "globe.asia.australia.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.green)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Local Life AI")
                    .font(.system(size: 32, weight: .bold))

                Text(viewModel.welcomeMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    var contextSection: some View {
        VStack(spacing: 12) {
            glassCard {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Selected area")
                        .font(.headline)

                    Text(viewModel.currentAreaTitle)
                        .font(.title3.weight(.semibold))
                }
            }

            glassCard {
                VStack(spacing: 16) {
                    userInfoRow(title: "Full Name", value: viewModel.user.fullName)
                    userInfoRow(title: "Email", value: viewModel.user.email)
                    userInfoRow(title: "Role", value: viewModel.user.role)
                }
            }
        }
    }

    var provinceListSection: some View {
        glassCard {

            VStack(alignment: .leading, spacing: 12) {

                Text("Pick a province or city")
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
                        .padding(.top, 4)
                    }
                }
            }
        }
    }

    func provinceRow(_ province: Province) -> some View {
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
        .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }

    func userInfoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)

            Spacer()

            Text(value)
                .foregroundStyle(.secondary)
        }
    }

    func glassCard<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.white.opacity(0.45), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 10)
    }

    var backgroundView: some View {
        LinearGradient(
            colors: [
                Color.green.opacity(0.12),
                Color.white
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(Color.green.opacity(0.12))
                .frame(width: 220)
                .blur(radius: 40)
                .offset(x: 80, y: -40)
        }
    }
}
