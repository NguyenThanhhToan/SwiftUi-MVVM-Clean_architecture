//
//  SwiftDataNoteRepository.swift
//  swiftUI
//
//  This repository owns the local SwiftData persistence. The domain layer only
//  sees note entities and use cases.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataNoteRepository: NoteRepository {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func fetchNote(for date: Date) async throws -> NoteEntry? {
        let context = ModelContext(modelContainer)
        let dateKey = date.notesStorageKey
        let descriptor = FetchDescriptor<NoteRecord>(
            predicate: #Predicate { $0.dateKey == dateKey }
        )

        let records = try context.fetch(descriptor)
        guard let record = records.first else { return nil }

        return NoteEntry(date: date.startOfDay, content: record.content)
    }

    func saveNote(content: String, for date: Date) async throws -> NoteEntry {
        let context = ModelContext(modelContainer)
        let dateKey = date.notesStorageKey
        let descriptor = FetchDescriptor<NoteRecord>(
            predicate: #Predicate { $0.dateKey == dateKey }
        )

        let records = try context.fetch(descriptor)
        let record = records.first ?? NoteRecord(dateKey: dateKey, content: content)
        record.content = content
        record.updatedAt = .now

        if records.isEmpty {
            context.insert(record)
        }

        try context.save()
        return NoteEntry(date: date.startOfDay, content: content)
    }
}

