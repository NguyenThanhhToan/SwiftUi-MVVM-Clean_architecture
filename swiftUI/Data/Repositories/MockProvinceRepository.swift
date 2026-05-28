//
//  MockProvinceRepository.swift
//  swiftUI
//
//  This mock mirrors the expected GHN province payload so the app is ready to
//  swap in a real network client later with minimal change.
//

import Foundation

final class MockProvinceRepository: ProvinceRepository {
    func fetchProvinces() async throws -> [Province] {
        try await Task.sleep(nanoseconds: 500_000_000)

        let request = URLRequest(url: URL(string: "mock://provinces")!)
        APILogger.logRequest(request, apiName: "Mock Get Provinces")

        let provinces = [
            Province(provinceID: 2002, provinceName: "Hà Nội", countryID: 1, code: "4"),
            Province(provinceID: 202, provinceName: "Hồ Chí Minh", countryID: 1, code: "8"),
            Province(provinceID: 201, provinceName: "Đà Nẵng", countryID: 1, code: "511"),
            Province(provinceID: 269, provinceName: "Cần Thơ", countryID: 1, code: "710"),
            Province(provinceID: 226, provinceName: "Hải Phòng", countryID: 1, code: "31")
        ]

        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        ) ?? URLResponse(url: request.url!, mimeType: "application/json", expectedContentLength: -1, textEncodingName: nil)

        let encodedData = try JSONEncoder().encode(
            provinces.map {
                ProvinceDTO(
                    provinceID: $0.provinceID,
                    provinceName: $0.provinceName,
                    countryID: $0.countryID,
                    code: $0.code
                )
            }
        )

        APILogger.logResponse(response, data: encodedData, apiName: "Mock Get Provinces")
        return provinces
    }
}
