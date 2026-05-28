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
    case settings

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .home:
            return "Home"
        case .notes:
            return "Notes"
        case .settings:
            return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .home:
            return "house.fill"
        case .notes:
            return "note.text"
        case .settings:
            return "gearshape.fill"
        }
    }
}
