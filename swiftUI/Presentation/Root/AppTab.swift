//
//  AppTab.swift
//  swiftUI
//
//  Tabs are modeled as an enum so the authenticated shell can grow without
//  hardcoding view logic in multiple places.
//

import Foundation

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case notes
    case chat
    case settings

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .home:
            return "Location"
        case .notes:
            return "Notes"
        case .chat:
            return "AI"
        case .settings:
            return "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .home:
            return "mappin.and.ellipse"
        case .notes:
            return "note.text"
        case .chat:
            return "sparkles"
        case .settings:
            return "person.crop.circle.fill"
        }
    }
}
