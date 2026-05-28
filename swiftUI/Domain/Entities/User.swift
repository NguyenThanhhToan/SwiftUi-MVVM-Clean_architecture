//
//  User.swift
//  swiftUI
//
//  Domain models describe the business data the app works with.
//  They are independent of UI and networking details.
//

import Foundation

struct User: Identifiable, Equatable, Codable {
    let id: UUID
    let fullName: String
    let email: String
    let role: String
}
