//
//  NoteRepository.swift
//  swiftUI
//
//  The repository contract hides the persistence implementation. Today it uses
//  SwiftData, but the app only depends on this abstraction.
//

import Foundation

protocol NoteRepository {
    func fetchNotes(in area: LocalAreaContext, query: String?) async throws -> [LocalNote]
    func save(note: LocalNote) async throws -> LocalNote
    func delete(noteID: UUID) async throws
}
