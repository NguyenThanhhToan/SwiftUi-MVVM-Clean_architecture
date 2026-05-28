//
//  GhnProvinceRepository.swift
//  swiftUI
//
//  This repository performs the real GHN request using async/await. The
//  repository remains the only place that knows about headers, URLs, and the
//  response shape.
//

import Foundation

final class GhnProvinceRepository: ProvinceRepository {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchProvinces() async throws -> [Province] {
        var request = URLRequest(url: URL(string: "https://dev-online-gateway.ghn.vn/shiip/public-api/master-data/province")!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("8ff33aa8-baa7-11ef-9083-dadc35c0870d", forHTTPHeaderField: "Token")

        APILogger.logRequest(request, apiName: "Get Provinces")

        do {
            let (data, response) = try await session.data(for: request)
            APILogger.logResponse(response, data: data, apiName: "Get Provinces")
            try validate(response: response, data: data)

            let decodedResponse = try JSONDecoder().decode(ProvinceResponseDTO.self, from: data)
            APILogger.logDecodedResponse(decodedResponse, apiName: "Get Provinces")

            guard decodedResponse.code == 200 else {
                throw URLError(.badServerResponse)
            }

            return decodedResponse.data.map { $0.toDomain() }
        } catch {
            APILogger.logError(error, apiName: "Get Provinces")
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
