//
//  GetNoteUseCase.swift
//  swiftUI
//
//  The Notes screen asks this use case to hydrate the editor for the selected
//  date. The view model never talks to storage directly.
//

import Foundation

struct GetNoteUseCase {
    let noteRepository: NoteRepository

    func execute(for date: Date) async throws -> NoteEntry? {
        try await noteRepository.fetchNote(for: date)
    }
}

