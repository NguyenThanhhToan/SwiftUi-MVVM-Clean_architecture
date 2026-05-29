//
//  NoteEditorCard.swift
//  swiftUI
//
//  The editor card keeps the note input styling consistent and reusable.
//

import SwiftUI

struct NoteEditorCard: View {
    @Binding var text: String
    let isSaving: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextEditor(text: $text)
                .frame(minHeight: 220)
                .scrollContentBackground(.hidden)
                .padding(12)
                .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

