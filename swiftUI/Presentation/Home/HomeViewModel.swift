//
//  HomeViewModel.swift
//  swiftUI
//
//  The home screen receives already-authenticated domain data and formats it
//  for display.
//

import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    let user: User
    @Published private(set) var provinces: [Province] = []
    @Published private(set) var isLoadingProvinces = false
    @Published var errorMessage: String?
    @Published var selectedProvince: Province?

    private let getProvincesUseCase: GetProvincesUseCase

    init(user: User, getProvincesUseCase: GetProvincesUseCase) {
        self.user = user
        self.getProvincesUseCase = getProvincesUseCase
    }

    var welcomeMessage: String {
        "Welcome, \(user.fullName)"
    }

    func loadProvinces() async {
        guard provinces.isEmpty, !isLoadingProvinces else { return }

        isLoadingProvinces = true
        errorMessage = nil
        defer { isLoadingProvinces = false }

        do {
            provinces = try await getProvincesUseCase.execute()
        } catch {
            errorMessage = "Unable to load provinces right now."
        }
    }

    func selectProvince(_ province: Province) {
        selectedProvince = province

        // District fetching will plug into this path later once the API exists.
        // The selected province is kept in state so a future district use case
        // can be triggered from the same interaction point.
        print("Selected ProvinceID: \(province.provinceID)")
        print("Selected ProvinceName: \(province.provinceName)")
    }
}
