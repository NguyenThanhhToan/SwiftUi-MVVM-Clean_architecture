//
//  NotesViewModel.swift
//  swiftUI
//
//  The view model owns selection state, autosave behavior, and loading notes
//  for the selected date. The view only forwards user intent.
//

import Combine
import Foundation

@MainActor
final class NotesViewModel: ObservableObject {
    @Published private(set) var months: [Date]
    @Published private(set) var days: [Date] = []
    @Published private(set) var isLoadingNote = false
    @Published private(set) var isSavingNote = false
    @Published var selectedMonth: Date
    @Published var selectedDay: Date
    @Published var noteText: String = ""
    @Published var errorMessage: String?

    private let getNoteUseCase: GetNoteUseCase
    private let saveNoteUseCase: SaveNoteUseCase
    private let calendar: Calendar
    private var saveTask: Task<Void, Never>?
    private var isApplyingLoadedNote = false

    init(
        getNoteUseCase: GetNoteUseCase,
        saveNoteUseCase: SaveNoteUseCase,
        calendar: Calendar = .current
    ) {
        self.getNoteUseCase = getNoteUseCase
        self.saveNoteUseCase = saveNoteUseCase
        self.calendar = calendar

        let today = calendar.startOfDay(for: Date())
        self.months = Self.makeMonths(for: today, calendar: calendar)
        self.selectedMonth = today.startOfMonth(using: calendar)
        self.selectedDay = today
        self.days = Self.makeDays(for: today.startOfMonth(using: calendar), calendar: calendar)
    }

    var selectedMonthTitle: String {
        Date.notesMonthTitleFormatter.string(from: selectedMonth)
    }

    func start() async {
        await loadNote(for: selectedDay)
    }

    func selectMonth(_ month: Date) {
        selectedMonth = month.startOfMonth(using: calendar)
        days = Self.makeDays(for: selectedMonth, calendar: calendar)

        let day = min(selectedDay.componentDay(using: calendar), calendar.range(of: .day, in: .month, for: selectedMonth)?.count ?? 1)
        selectedDay = calendar.date(bySetting: .day, value: day, of: selectedMonth) ?? selectedMonth

        Task {
            await loadNote(for: selectedDay)
        }
    }

    func selectDay(_ day: Date) {
        guard day != selectedDay else { return }
        selectedDay = day.startOfDay
        Task {
            await loadNote(for: selectedDay)
        }
    }

    func noteTextChanged(_ text: String) {
        guard !isApplyingLoadedNote else { return }

        let noteDate = selectedDay
        saveTask?.cancel()
        saveTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: 450_000_000)
            guard !Task.isCancelled else { return }
            await self.saveNote(content: text, for: noteDate)
        }
    }

    private func loadNote(for date: Date) async {
        isLoadingNote = true
        errorMessage = nil
        defer { isLoadingNote = false }

        do {
            let existingNote = try await getNoteUseCase.execute(for: date)
            isApplyingLoadedNote = true
            noteText = existingNote?.content ?? ""
            isApplyingLoadedNote = false
        } catch {
            errorMessage = "Unable to load note for this date."
        }
    }

    private func saveNote(content: String, for date: Date) async {
        isSavingNote = true
        defer { isSavingNote = false }

        do {
            _ = try await saveNoteUseCase.execute(content: content, for: date)
        } catch {
            errorMessage = "Unable to save note right now."
        }
    }

    private static func makeMonths(for referenceDate: Date, calendar: Calendar) -> [Date] {
        guard let yearInterval = calendar.dateInterval(of: .year, for: referenceDate) else { return [] }
        let monthCount = 12

        return (0..<monthCount).compactMap { offset in
            calendar.date(byAdding: .month, value: offset, to: yearInterval.start)?.startOfMonth(using: calendar)
        }
    }

    private static func makeDays(for month: Date, calendar: Calendar) -> [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: month) else { return [] }
        return range.compactMap { day in
            calendar.date(bySetting: .day, value: day, of: month)?.startOfDay
        }
    }
}

private extension Date {
    func startOfMonth(using calendar: Calendar) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: self)) ?? self
    }

    func componentDay(using calendar: Calendar) -> Int {
        calendar.component(.day, from: self)
    }
}
