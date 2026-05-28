//
//  DistrictRepository.swift
//  swiftUI
//
//  The repository contract keeps district retrieval abstract so the app can
//  switch between mock and real data sources without touching presentation.
//

import Foundation

protocol DistrictRepository {
    func fetchDistricts(provinceID: Int) async throws -> [District]
}

