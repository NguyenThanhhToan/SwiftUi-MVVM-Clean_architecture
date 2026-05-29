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

    func execute(in area: LocalAreaContext, query: String? = nil) async throws -> [LocalNote] {
        try await noteRepository.fetchNotes(in: area, query: query)
    }
}
