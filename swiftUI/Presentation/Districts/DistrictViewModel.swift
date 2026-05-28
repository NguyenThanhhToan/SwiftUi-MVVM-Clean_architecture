//
//  DistrictViewModel.swift
//  swiftUI
//
//  The district screen only talks to a use case. It keeps the selected
//  province context and loads districts asynchronously when the screen appears.
//

import Combine
import Foundation

@MainActor
final class DistrictViewModel: ObservableObject {
    let province: Province
    @Published private(set) var districts: [District] = []
    @Published private(set) var isLoadingDistricts = false
    @Published var errorMessage: String?

    private let getDistrictsUseCase: GetDistrictsUseCase

    init(province: Province, getDistrictsUseCase: GetDistrictsUseCase) {
        self.province = province
        self.getDistrictsUseCase = getDistrictsUseCase
    }

    var title: String {
        province.provinceName
    }

    func loadDistricts() async {
        guard districts.isEmpty, !isLoadingDistricts else { return }

        isLoadingDistricts = true
        errorMessage = nil
        defer { isLoadingDistricts = false }

        do {
            districts = try await getDistrictsUseCase.execute(provinceID: province.provinceID)
        } catch {
            errorMessage = "Unable to load districts right now."
        }
    }
}

