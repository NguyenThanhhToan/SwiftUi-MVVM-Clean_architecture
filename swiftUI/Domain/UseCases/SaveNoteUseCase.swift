//
//  SaveNoteUseCase.swift
//  swiftUI
//
//  Saving notes is a separate use case so create/edit flows remain explicit and
//  easy to extend later with autosave, validation, or sync behavior.
//

import Foundation

struct SaveNoteUseCase {
    let noteRepository: NoteRepository

    func execute(content: String, for date: Date) async throws -> NoteEntry {
        try await noteRepository.saveNote(content: content, for: date)
    }
}

