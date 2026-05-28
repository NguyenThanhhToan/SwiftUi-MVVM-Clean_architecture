//
//  DaySelectorView.swift
//  swiftUI
//
//  The day selector uses centered scrolling so the current selection stays in
//  focus while the user moves through the month.
//

import SwiftUI

struct DaySelectorView: View {
    let days: [Date]
    @Binding var selectedDay: Date

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {

                ForEach(days, id: \.self) { day in

                    Button {

                        selectedDay = day

                    } label: {

                        VStack(spacing: 4) {

                            Text(Date.notesWeekdayFormatter.string(from: day))
                                .font(.caption.weight(.semibold))

                            Text(Date.notesDayTitleFormatter.string(from: day))
                                .font(.headline)
                        }
                        .frame(width: 68, height: 68)
                        .foregroundStyle(
                            selectedDay == day ? .white : .primary
                        )
                        .background(
                            selectedDay == day
                            ? Color.blue
                            : Color.gray.opacity(0.12),
                            in: RoundedRectangle(
                                cornerRadius: 18,
                                style: .continuous
                            )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 84)
    }
}
