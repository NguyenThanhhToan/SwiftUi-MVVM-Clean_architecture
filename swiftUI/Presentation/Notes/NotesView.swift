//
//  NotesView.swift
//  swiftUI
//
//  Notes is a self-contained tab. The view only composes reusable selector and
//  editor components and forwards user events to the view model.
//

import SwiftUI

struct NotesView: View {
    @StateObject private var viewModel: NotesViewModel

    init(viewModel: NotesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.largeTitle.bold())
                    Text("Create and edit notes by date.")
                        .foregroundStyle(.secondary)
                }

                MonthSelectorView(months: viewModel.months, selectedMonth: Binding(
                    get: { viewModel.selectedMonth },
                    set: { newValue in
                        viewModel.selectMonth(newValue)
                    }
                ))

                DaySelectorView(days: viewModel.days, selectedDay: Binding(
                    get: { viewModel.selectedDay },
                    set: { newValue in
                        viewModel.selectDay(newValue)
                    }
                ))

                NoteEditorCard(
                    text: Binding(
                        get: { viewModel.noteText },
                        set: { newValue in
                            viewModel.noteText = newValue
                            viewModel.noteTextChanged(newValue)
                        }
                    ),
                    isSaving: viewModel.isSavingNote
                )

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [Color.orange.opacity(0.12), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .task {
            await viewModel.start()
        }
    }
}

