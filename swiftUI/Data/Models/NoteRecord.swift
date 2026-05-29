//
//  NoteRecord.swift
//  swiftUI
//
//  SwiftData model used by the local database for location-aware notes.
//

import Foundation
import SwiftData

@Model
final class NoteRecord {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var categoryRawValue: String
    var provinceID: Int?
    var provinceName: String
    var districtID: Int?
    var districtName: String?
    var locationKey: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        categoryRawValue: String,
        provinceID: Int?,
        provinceName: String,
        districtID: Int?,
        districtName: String?,
        locationKey: String,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.categoryRawValue = categoryRawValue
        self.provinceID = provinceID
        self.provinceName = provinceName
        self.districtID = districtID
        self.districtName = districtName
        self.locationKey = locationKey
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
