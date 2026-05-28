//
//  DistrictView.swift
//  swiftUI
//
//  The district screen shows the province context and the loaded district
//  list. It is driven entirely by the view model.
//

import SwiftUI

struct DistrictView: View {
    @StateObject private var viewModel: DistrictViewModel

    init(viewModel: DistrictViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            Section("Selected Province") {
                row(title: "Province ID", value: "\(viewModel.province.provinceID)")
                row(title: "Province Name", value: viewModel.province.provinceName)
            }

            Section("Districts") {
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
                    ForEach(viewModel.districts) { district in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(district.districtName)
                                .font(.headline)
                            Text("District ID: \(district.districtID)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadDistricts()
        }
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

