//
//  MonthSelectorView.swift
//  swiftUI
//
//  Horizontal month chips are reusable so the selector can be tuned without
//  touching the Notes view model.
//

import SwiftUI

struct MonthSelectorView: View {
    let months: [Date]
    @Binding var selectedMonth: Date

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {

            LazyHStack(spacing: 12) {

                ForEach(months, id: \.self) { month in

                    Button {

                        selectedMonth = month

                    } label: {

                        Text(Date.notesMonthTitleFormatter.string(from: month))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(
                                selectedMonth == month
                                ? .white
                                : .primary
                            )
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(
                                selectedMonth == month
                                ? Color.blue
                                : Color.gray.opacity(0.12),
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 56)
    }
}
