//
//  Province.swift
//  swiftUI
//
//  Provinces are domain entities, so the presentation layer depends on this
//  model rather than on any API response shape.
//

import Foundation

struct Province: Identifiable, Equatable, Hashable {
    let provinceID: Int
    let provinceName: String
    let countryID: Int
    let code: String?

    var id: Int {
        provinceID
    }
}
