//
//  LocalAreaContext.swift
//  swiftUI
//
//  The selected province and district are shared app context for notes and
//  the AI assistant.
//

import Foundation

struct LocalAreaContext: Codable, Equatable, Hashable {
    let provinceID: Int?
    let provinceName: String
    let districtID: Int?
    let districtName: String?

    var displayTitle: String {
        switch (provinceName.trimmed, districtName?.trimmed ?? "") {
        case let (province, district) where !province.isEmpty && !district.isEmpty:
            return "\(province) · \(district)"
        case let (province, _) where !province.isEmpty:
            return province
        default:
            return "Select a location"
        }
    }

    var storageKey: String {
        let provincePart = provinceID.map(String.init) ?? "unknown"
        let districtPart = districtID.map(String.init) ?? "all"
        return "\(provincePart)-\(districtPart)"
    }
}

enum LocalNoteCategory: String, CaseIterable, Codable, Identifiable {
    case food
    case travel
    case work
    case health
    case places
    case reminder
    case other

    var id: String { rawValue }

    var title: String {
        rawValue.capitalized
    }

    var symbolName: String {
        switch self {
        case .food: return "fork.knife"
        case .travel: return "airplane"
        case .work: return "briefcase"
        case .health: return "heart.text.square"
        case .places: return "map"
        case .reminder: return "bell"
        case .other: return "square.grid.2x2"
        }
    }
}

struct LocalNote: Identifiable, Equatable, Hashable {
    let id: UUID
    var title: String
    var content: String
    var category: LocalNoteCategory
    var provinceID: Int?
    var provinceName: String
    var districtID: Int?
    var districtName: String?
    var createdAt: Date
    var updatedAt: Date

    var areaTitle: String {
        switch (provinceName.trimmed, districtName?.trimmed ?? "") {
        case let (province, district) where !province.isEmpty && !district.isEmpty:
            return "\(province) · \(district)"
        case let (province, _) where !province.isEmpty:
            return province
        default:
            return "No location"
        }
    }

    var locationKey: String {
        let provincePart = provinceID.map(String.init) ?? "unknown"
        let districtPart = districtID.map(String.init) ?? "all"
        return "\(provincePart)-\(districtPart)"
    }
}
