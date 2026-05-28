//
//  ProvinceResponseDTO.swift
//  swiftUI
//
//  Data transfer objects mirror the GHN response shape. They stay in the data
//  layer so the domain entity can remain clean and API-agnostic.
//

import Foundation

struct ProvinceResponseDTO: Codable {
    let code: Int
    let message: String
    let data: [ProvinceDTO]
}

struct ProvinceDTO: Codable {
    let provinceID: Int
    let provinceName: String
    let countryID: Int
    let code: String?

    enum CodingKeys: String, CodingKey {
        case provinceID = "ProvinceID"
        case provinceName = "ProvinceName"
        case countryID = "CountryID"
        case code = "Code"
    }

    func toDomain() -> Province {
        Province(
            provinceID: provinceID,
            provinceName: provinceName,
            countryID: countryID,
            code: code
        )
    }
}
