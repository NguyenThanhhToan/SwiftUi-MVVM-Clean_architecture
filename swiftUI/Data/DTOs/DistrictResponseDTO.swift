//
//  DistrictResponseDTO.swift
//  swiftUI
//
//  DTOs mirror the GHN district response while tolerating extra fields. Only
//  the values needed by the app are mapped into the domain entity.
//

import Foundation

struct DistrictResponseDTO: Codable {
    let code: Int
    let message: String
    let data: [DistrictDTO]
}

struct DistrictDTO: Codable {
    let districtID: Int
    let districtName: String
    let provinceID: Int
    let code: String?

    enum CodingKeys: String, CodingKey {
        case districtID = "DistrictID"
        case districtName = "DistrictName"
        case provinceID = "ProvinceID"
        case code = "Code"
    }

    func toDomain() -> District {
        District(
            districtID: districtID,
            districtName: districtName,
            provinceID: provinceID,
            code: code
        )
    }
}

