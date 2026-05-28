//
//  NoteRepository.swift
//  swiftUI
//
//  The repository contract hides the persistence implementation. Today it uses
//  SwiftData, but the app only depends on this abstraction.
//

import Foundation

protocol NoteRepository {
    func fetchNote(for date: Date) async throws -> NoteEntry?
    func saveNote(content: String, for date: Date) async throws -> NoteEntry
}

