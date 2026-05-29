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
        ZStack {
            backgroundView

            VStack(spacing: 24) {
                headerSection

                contentSection

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .task {
            await viewModel.start()
        }
    }
}

// MARK: - UI Sections

private extension NotesView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {

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
                    Text("Notes")
                        .font(.system(size: 34, weight: .bold))

                    Text("Create and edit notes by date")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
    }

    var contentSection: some View {
        VStack(spacing: 18) {

            cardView {
                MonthSelectorView(
                    months: viewModel.months,
                    selectedMonth: Binding(
                        get: { viewModel.selectedMonth },
                        set: { newValue in
                            viewModel.selectMonth(newValue)
                        }
                    )
                )
            }

            cardView {
                DaySelectorView(
                    days: viewModel.days,
                    selectedDay: Binding(
                        get: { viewModel.selectedDay },
                        set: { newValue in
                            viewModel.selectDay(newValue)
                        }
                    )
                )
            }

            cardView {
                VStack(alignment: .leading, spacing: 14) {

                    HStack {
                        Label("Your Note", systemImage: "square.and.pencil")
                            .font(.headline)

                        Spacer()

                        if viewModel.isSavingNote {
                            ProgressView()
                                .scaleEffect(0.85)
                        }
                    }

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
                }
            }

            if let errorMessage = viewModel.errorMessage {
                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.red)

                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)

                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.red.opacity(0.08))
                )
            }
        }
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

    func cardView<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
            )
            .shadow(
                color: .black.opacity(0.06),
                radius: 20,
                x: 0,
                y: 10
            )
    }
}
