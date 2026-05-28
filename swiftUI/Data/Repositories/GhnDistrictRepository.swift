//
//  GhnDistrictRepository.swift
//  swiftUI
//
//  This repository calls the real GHN district endpoint using the selected
//  province ID. The request body is kept here so the rest of the app can stay
//  unaware of transport details.
//

import Foundation

final class GhnDistrictRepository: DistrictRepository {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchDistricts(provinceID: Int) async throws -> [District] {
        var request = URLRequest(url: URL(string: "https://dev-online-gateway.ghn.vn/shiip/public-api/master-data/district")!)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("8ff33aa8-baa7-11ef-9083-dadc35c0870d", forHTTPHeaderField: "token")
        request.httpBody = try JSONSerialization.data(
            withJSONObject: ["province_id": provinceID],
            options: []
        )

        APILogger.logRequest(request, apiName: "Get Districts")

        do {
            let (data, response) = try await session.data(for: request)
            APILogger.logResponse(response, data: data, apiName: "Get Districts")
            try validate(response: response, data: data)

            let decodedResponse = try JSONDecoder().decode(DistrictResponseDTO.self, from: data)
            APILogger.logDecodedResponse(decodedResponse, apiName: "Get Districts")

            guard decodedResponse.code == 200 else {
                throw URLError(.badServerResponse)
            }

            return decodedResponse.data.map { $0.toDomain() }
        } catch {
            APILogger.logError(error, apiName: "Get Districts")
            throw error
        }
    }

    private func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        guard !data.isEmpty else {
            throw URLError(.zeroByteResource)
        }
    }
}
