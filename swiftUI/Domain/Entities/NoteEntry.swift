//
//  NoteEntry.swift
//  swiftUI
//
//  Notes belong to the domain layer so the UI can work with a stable model
//  regardless of how they are stored locally.
//

import Foundation

struct NoteEntry: Identifiable, Equatable, Hashable {
    let date: Date
    let content: String

    var id: String {
        date.notesStorageKey
    }
}

