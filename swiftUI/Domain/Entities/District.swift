//
//  District.swift
//  swiftUI
//
//  Districts are the next level of location data beneath provinces. Keeping
//  them in Domain lets the UI remain stable if the backend changes later.
//

import Foundation

struct District: Identifiable, Equatable, Hashable {
    let districtID: Int
    let districtName: String
    let provinceID: Int
    let code: String?

    var id: Int {
        districtID
    }
}
