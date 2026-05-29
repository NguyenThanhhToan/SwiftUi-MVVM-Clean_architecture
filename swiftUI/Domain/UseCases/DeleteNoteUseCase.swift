//
//  DeleteNoteUseCase.swift
//  swiftUI
//
//  Deleting a note stays behind a use case so the UI does not touch storage.
//

import Foundation

struct DeleteNoteUseCase {
    let noteRepository: NoteRepository

    func execute(noteID: UUID) async throws {
        try await noteRepository.delete(noteID: noteID)
    }
}
