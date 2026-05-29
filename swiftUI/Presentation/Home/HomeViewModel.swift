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
    @Published private(set) var currentAreaTitle: String = "Select a province and district"

    private let getProvincesUseCase: GetProvincesUseCase
    private let localAreaContextStore: LocalAreaContextStoring

    init(user: User, getProvincesUseCase: GetProvincesUseCase, localAreaContextStore: LocalAreaContextStoring) {
        self.user = user
        self.getProvincesUseCase = getProvincesUseCase
        self.localAreaContextStore = localAreaContextStore
        self.currentAreaTitle = localAreaContextStore.currentContext?.displayTitle ?? "Select a province and district"
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
        localAreaContextStore.currentContext = LocalAreaContext(
            provinceID: province.provinceID,
            provinceName: province.provinceName,
            districtID: nil,
            districtName: nil
        )
        currentAreaTitle = localAreaContextStore.currentContext?.displayTitle ?? province.provinceName
    }
}
