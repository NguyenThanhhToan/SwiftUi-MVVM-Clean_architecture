//
//  NotesViewModel.swift
//  swiftUI
//
//  The notes screen is location-aware. It can create, edit, delete, search,
//  and filter notes for the currently selected province/district.
//

import Combine
import Foundation

@MainActor
final class NotesViewModel: ObservableObject {
    @Published private(set) var notes: [LocalNote] = []
    @Published private(set) var isLoadingNotes = false
    @Published private(set) var isSavingNote = false
    @Published private(set) var isDeletingNote = false
    @Published var searchText: String = ""
    @Published var selectedCategory: LocalNoteCategory? = nil
    @Published var draftTitle: String = ""
    @Published var draftContent: String = ""
    @Published var draftCategory: LocalNoteCategory = .travel
    @Published var errorMessage: String?

    private let getNoteUseCase: GetNoteUseCase
    private let saveNoteUseCase: SaveNoteUseCase
    private let deleteNoteUseCase: DeleteNoteUseCase
    private let localAreaContextStore: LocalAreaContextStoring
    private var editingNoteID: UUID?

    init(
        getNoteUseCase: GetNoteUseCase,
        saveNoteUseCase: SaveNoteUseCase,
        deleteNoteUseCase: DeleteNoteUseCase,
        localAreaContextStore: LocalAreaContextStoring
    ) {
        self.getNoteUseCase = getNoteUseCase
        self.saveNoteUseCase = saveNoteUseCase
        self.deleteNoteUseCase = deleteNoteUseCase
        self.localAreaContextStore = localAreaContextStore
    }

    var currentAreaTitle: String {
        localAreaContextStore.currentContext?.displayTitle ?? "Select a province and district"
    }

    var filteredNotes: [LocalNote] {
        notes.filter { note in
            guard let selectedCategory else { return true }
            return note.category == selectedCategory
        }
    }

    var isEditing: Bool {
        editingNoteID != nil
    }

    func start() async {
        await loadNotes()
    }

    func refresh() async {
        await loadNotes()
    }

    func selectCategory(_ category: LocalNoteCategory?) {
        selectedCategory = category
    }

    func edit(note: LocalNote) {
        editingNoteID = note.id
        draftTitle = note.title
        draftContent = note.content
        draftCategory = note.category
    }

    func clearDraft() {
        editingNoteID = nil
        draftTitle = ""
        draftContent = ""
        draftCategory = .travel
    }

    func saveDraft() {
        let title = draftTitle.trimmed
        let content = draftContent.trimmed
        guard !title.isEmpty || !content.isEmpty else { return }
        guard let context = localAreaContextStore.currentContext else {
            errorMessage = "Select a location first."
            return
        }

        isSavingNote = true
        errorMessage = nil

        Task {
            await saveDraft(with: context, title: title, content: content)
        }
    }

    func delete(note: LocalNote) {
        isDeletingNote = true
        errorMessage = nil

        Task {
            await performDelete(note: note)
        }
    }

    func loadNotes() async {
        isLoadingNotes = true
        errorMessage = nil
        defer { isLoadingNotes = false }

        guard let context = localAreaContextStore.currentContext else {
            notes = []
            return
        }

        do {
            notes = try await getNoteUseCase.execute(in: context, query: searchText)
        } catch {
            errorMessage = "Unable to load notes for this location."
        }
    }

    private func saveDraft(with context: LocalAreaContext, title: String, content: String) async {
        defer { isSavingNote = false }

        let note = LocalNote(
            id: editingNoteID ?? UUID(),
            title: title.isEmpty ? "Untitled note" : title,
            content: content,
            category: draftCategory,
            provinceID: context.provinceID,
            provinceName: context.provinceName,
            districtID: context.districtID,
            districtName: context.districtName,
            createdAt: Date(),
            updatedAt: Date()
        )

        do {
            _ = try await saveNoteUseCase.execute(note: note)
            clearDraft()
            await loadNotes()
        } catch {
            errorMessage = "Unable to save note right now."
        }
    }

    private func performDelete(note: LocalNote) async {
        defer { isDeletingNote = false }

        do {
            try await deleteNoteUseCase.execute(noteID: note.id)
            if editingNoteID == note.id {
                clearDraft()
            }
            await loadNotes()
        } catch {
            errorMessage = "Unable to delete note right now."
        }
    }
}
