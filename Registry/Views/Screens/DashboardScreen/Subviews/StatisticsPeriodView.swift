//
//  StatisticsPeriodView.swift
//  Registry
//
//  Created by Николай Фаустов on 13.06.2024.
//

import SwiftUI

struct StatisticsPeriodView: View {
    // MARK: - Dependencies

    @Binding var date: Date
    @Binding var selectedPeriod: StatisticsPeriod

    // MARK: -

    var body: some View {
        HStack(spacing: 0) {
            DatePicker("", selection: $date, in: .distantPast...Date.now, displayedComponents: .date)

            Picker("Выбранный период", selection: $selectedPeriod) {
                ForEach(StatisticsPeriod.allCases) { period in
                    Text(period.rawValue)
                }
            }
            .pickerStyle(.menu)
            .tint(.secondary)
            .frame(width: 100)

            HStack {
                DateText(selectedPeriod.start(for: date), format: .dayMonth)
                Text("-")
                DateText(selectedPeriod.end(for: date), format: .dayMonth)
            }
            .font(.footnote)
            .frame(width: 100)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 11)
        .frame(width: 360)
        .frame(maxHeight: .infinity)
        .colorInvert()
        .background(Color(.appBlack), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    StatisticsPeriodView(date: .constant(.now), selectedPeriod: .constant(.day))
}
