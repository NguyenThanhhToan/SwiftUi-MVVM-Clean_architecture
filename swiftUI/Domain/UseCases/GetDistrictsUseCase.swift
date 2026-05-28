//
//  GetDistrictsUseCase.swift
//  swiftUI
//
//  The district screen asks this use case for data, not the repository
//  directly. That keeps the presentation layer focused on state and navigation.
//

import Foundation

struct GetDistrictsUseCase {
    let districtRepository: DistrictRepository

    func execute(provinceID: Int) async throws -> [District] {
        try await districtRepository.fetchDistricts(provinceID: provinceID)
    }
}

