//
//  SwiftDataNoteRepository.swift
//  swiftUI
//
//  This repository owns local note persistence for location-aware notes.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataNoteRepository: NoteRepository {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func fetchNotes(in area: LocalAreaContext, query: String? = nil) async throws -> [LocalNote] {
        let context = ModelContext(modelContainer)
        let locationKey = area.storageKey
        let descriptor = FetchDescriptor<NoteRecord>(
            predicate: #Predicate { $0.locationKey == locationKey },
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )

        let records = try context.fetch(descriptor)
        let notes = records.map { $0.toDomain() }

        guard let query else { return notes }
        let trimmedQuery = query.trimmed.lowercased()
        guard !trimmedQuery.isEmpty else { return notes }

        return notes.filter {
            $0.title.lowercased().contains(trimmedQuery) ||
            $0.content.lowercased().contains(trimmedQuery) ||
            $0.category.title.lowercased().contains(trimmedQuery)
        }
    }

    func save(note: LocalNote) async throws -> LocalNote {
        let context = ModelContext(modelContainer)
        let noteID = note.id
        let descriptor = FetchDescriptor<NoteRecord>(
            predicate: #Predicate { $0.id == noteID }
        )

        let records = try context.fetch(descriptor)
        let record = records.first ?? NoteRecord(
            id: note.id,
            title: note.title,
            content: note.content,
            categoryRawValue: note.category.rawValue,
            provinceID: note.provinceID,
            provinceName: note.provinceName,
            districtID: note.districtID,
            districtName: note.districtName,
            locationKey: note.locationKey,
            createdAt: note.createdAt,
            updatedAt: note.updatedAt
        )

        record.title = note.title
        record.content = note.content
        record.categoryRawValue = note.category.rawValue
        record.provinceID = note.provinceID
        record.provinceName = note.provinceName
        record.districtID = note.districtID
        record.districtName = note.districtName
        record.locationKey = note.locationKey
        record.updatedAt = .now

        if records.isEmpty {
            context.insert(record)
        }

        try context.save()
        return record.toDomain()
    }

    func delete(noteID: UUID) async throws {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<NoteRecord>(
            predicate: #Predicate { $0.id == noteID }
        )

        let records = try context.fetch(descriptor)
        for record in records {
            context.delete(record)
        }

        try context.save()
    }
}

private extension NoteRecord {
    func toDomain() -> LocalNote {
        LocalNote(
            id: id,
            title: title,
            content: content,
            category: LocalNoteCategory(rawValue: categoryRawValue) ?? .other,
            provinceID: provinceID,
            provinceName: provinceName,
            districtID: districtID,
            districtName: districtName,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
