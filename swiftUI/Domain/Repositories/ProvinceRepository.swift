//
//  ProvinceRepository.swift
//  swiftUI
//
//  Repository protocols stay in the domain layer so the app can swap a mock
//  implementation for a real GHN API client later without changing UI code.
//

import Foundation

protocol ProvinceRepository {
    func fetchProvinces() async throws -> [Province]
}

