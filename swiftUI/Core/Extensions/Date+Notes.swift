//
//  Date+Notes.swift
//  swiftUI
//
//  Shared date helpers keep the Notes feature consistent across the view model,
//  repository, and reusable selector views.
//

import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var notesStorageKey: String {
        Self.notesKeyFormatter.string(from: startOfDay)
    }

    static let notesKeyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = .init(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let notesMonthTitleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = .current
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()

    static let notesDayTitleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = .current
        formatter.dateFormat = "d"
        return formatter
    }()

    static let notesWeekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = .current
        formatter.dateFormat = "EEE"
        return formatter
    }()
}

