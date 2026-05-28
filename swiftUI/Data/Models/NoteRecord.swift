//
//  NoteRecord.swift
//  swiftUI
//
//  SwiftData model used by the local database. This stays in Data so the rest
//  of the app can remain decoupled from persistence details.
//

import Foundation
import SwiftData

@Model
final class NoteRecord {
    @Attribute(.unique) var dateKey: String
    var content: String
    var updatedAt: Date

    init(dateKey: String, content: String, updatedAt: Date = .now) {
        self.dateKey = dateKey
        self.content = content
        self.updatedAt = updatedAt
    }
}

