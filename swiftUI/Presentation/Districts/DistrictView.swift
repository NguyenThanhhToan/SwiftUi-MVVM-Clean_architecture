//
//  DistrictView.swift
//  swiftUI
//
//  The district screen completes the location selection flow.
//

import SwiftUI

struct DistrictView: View {
    @StateObject private var viewModel: DistrictViewModel

    init(viewModel: DistrictViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                headerSection
                selectedProvinceSection
                districtsSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(backgroundView)
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadDistricts()
        }
    }
}

private extension DistrictView {
    var headerSection: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .frame(width: 56, height: 56)

                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.blue)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Choose district")
                    .font(.system(size: 30, weight: .bold))

                Text("Complete the location context for notes and AI chat")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    var selectedProvinceSection: some View {
        glassCard {
            VStack(alignment: .leading, spacing: 6) {
                Text("Selected province")
                    .font(.headline)
                Text(viewModel.province.provinceName)
                    .font(.title3.weight(.semibold))
                Text("Province ID: \(viewModel.province.provinceID)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    var districtsSection: some View {
        glassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Districts")
                    .font(.headline)

                if viewModel.isLoadingDistricts {
                    HStack {
                        ProgressView()
                        Text("Loading districts...")
                            .foregroundStyle(.secondary)
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.districts) { district in
                            Button {
                                viewModel.selectDistrict(district)
                            } label: {
                                districtRow(district)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    func districtRow(_ district: District) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(district.districtName)
                    .font(.headline)
                Text("District ID: \(district.districtID)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: viewModel.selectedDistrict?.districtID == district.districtID ? "checkmark.circle.fill" : "chevron.right")
                .foregroundStyle(viewModel.selectedDistrict?.districtID == district.districtID ? .green : .secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
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
                Color.blue.opacity(0.12),
                Color.white
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(Color.blue.opacity(0.12))
                .frame(width: 220)
                .blur(radius: 40)
                .offset(x: 80, y: -40)
        }
    }
}
