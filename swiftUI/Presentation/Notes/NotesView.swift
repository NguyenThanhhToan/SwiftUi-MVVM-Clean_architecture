//
//  NotesView.swift
//  swiftUI
//
//  Location-aware notes with search, categories, edit, and delete actions.
//

import SwiftUI

struct NotesView: View {
    @StateObject private var viewModel: NotesViewModel

    init(viewModel: NotesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            backgroundView

            ScrollView {
                VStack(spacing: 18) {
                    headerSection
                    locationSection
                    composerSection
                    notesSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .task {
            await viewModel.start()
        }
    }
}

private extension NotesView {
    var headerSection: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .frame(width: 56, height: 56)

                Image(systemName: "note.text")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.orange)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Local Notes")
                    .font(.system(size: 32, weight: .bold))

                Text("Capture places, food, travel and reminders for each area")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    var locationSection: some View {
        glassCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Current area", systemImage: "mappin.and.ellipse")
                    .font(.headline)

                Text(viewModel.currentAreaTitle)
                    .font(.title3.weight(.semibold))

                if viewModel.isSavingNote {
                    ProgressView("Saving note...")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    var composerSection: some View {
        glassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label(viewModel.isEditing ? "Edit note" : "New note", systemImage: "square.and.pencil")
                        .font(.headline)

                    Spacer()

                    Button(viewModel.isEditing ? "Cancel" : "Clear") {
                        viewModel.clearDraft()
                    }
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
                }

                TextField("Title", text: $viewModel.draftTitle)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 16))

                Picker("Category", selection: $viewModel.draftCategory) {
                    ForEach(LocalNoteCategory.allCases) { category in
                        Text(category.title).tag(category)
                    }
                }
                .pickerStyle(.menu)

                TextField("Write something useful about this area...", text: $viewModel.draftContent, axis: .vertical)
                    .lineLimit(4...8)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 16))

                Button {
                    viewModel.saveDraft()
                } label: {
                    HStack {
                        Spacer()
                        Text(viewModel.isEditing ? "Update note" : "Save note")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [.orange, .red.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 18)
                    )
                    .foregroundStyle(.white)
                }
                .disabled(viewModel.draftTitle.trimmed.isEmpty && viewModel.draftContent.trimmed.isEmpty)
            }
        }
    }

    var notesSection: some View {
        VStack(spacing: 12) {
            glassCard {
                VStack(spacing: 12) {
                    HStack {
                        Text("Saved notes")
                            .font(.headline)

                        Spacer()
                    }

                    TextField("Search notes", text: $viewModel.searchText)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 16))
                        .onChange(of: viewModel.searchText) { _, _ in
                            Task { await viewModel.loadNotes() }
                        }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            categoryChip(title: "All", isSelected: viewModel.selectedCategory == nil) {
                                viewModel.selectCategory(nil)
                            }

                            ForEach(LocalNoteCategory.allCases) { category in
                                categoryChip(title: category.title, icon: category.symbolName, isSelected: viewModel.selectedCategory == category) {
                                    viewModel.selectCategory(category)
                                }
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }

            if viewModel.isLoadingNotes {
                glassCard {
                    HStack {
                        ProgressView()
                        Text("Loading notes...")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            } else if let errorMessage = viewModel.errorMessage {
                glassCard {
                    Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }
            } else if viewModel.filteredNotes.isEmpty {
                glassCard {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("No notes yet")
                            .font(.headline)
                        Text("Save a note for this location and use Gemini to summarize or reorganize it later.")
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredNotes) { note in
                        noteCard(note)
                    }
                }
            }
        }
    }

    func noteCard(_ note: LocalNote) -> some View {
        glassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.title)
                            .font(.headline)

                        Text(note.areaTitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(note.category.title)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.12), in: Capsule())
                }

                Text(note.content)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(4)

                HStack {
                    Button("Edit") {
                        viewModel.edit(note: note)
                    }
                    .font(.footnote.weight(.semibold))

                    Spacer()

                    Button(role: .destructive) {
                        viewModel.delete(note: note)
                    } label: {
                        Text("Delete")
                            .font(.footnote.weight(.semibold))
                    }
                }
            }
        }
    }

    func categoryChip(
        title: String,
        icon: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.footnote.weight(.medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                isSelected ? Color.orange.opacity(0.18) : Color.white.opacity(0.72),
                in: Capsule()
            )
            .foregroundStyle(isSelected ? .primary : .secondary)
        }
    }

    func glassCard<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.white.opacity(0.45), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 10)
    }

    var backgroundView: some View {
        LinearGradient(
            colors: [
                Color.orange.opacity(0.15),
                Color.yellow.opacity(0.08),
                Color.white
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(Color.orange.opacity(0.12))
                .frame(width: 220)
                .blur(radius: 40)
                .offset(x: 80, y: -40)
        }
    }
}
