//
//  GetProvincesUseCase.swift
//  swiftUI
//
//  The home screen asks the use case for provinces. The use case keeps the
//  business flow simple and shields the view model from repository details.
//

import Foundation

struct GetProvincesUseCase {
    let provinceRepository: ProvinceRepository

    func execute() async throws -> [Province] {
        try await provinceRepository.fetchProvinces()
    }
}

