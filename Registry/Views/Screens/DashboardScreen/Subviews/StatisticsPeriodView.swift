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
        HStack(spacing: 32) {
            DatePicker("", selection: $date, displayedComponents: .date)
            HStack {
                DateText(selectedPeriod.start(for: date), format: .date)
                    .font(.subheadline)
                Text("-")
                    .font(.subheadline)
                DateText(selectedPeriod.end(for: date), format: .date)
                    .font(.subheadline)
                Picker("Выбранный период", selection: $selectedPeriod) {
                    ForEach(StatisticsPeriod.allCases) { period in
                        Text(period.rawValue)
                    }
                }
                .pickerStyle(.menu)
                .tint(.secondary)
                .frame(width: 100, alignment: .trailing)
            }
            .padding(.horizontal, 8)
            .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .padding(8)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StatisticsPeriodView(date: .constant(.now), selectedPeriod: .constant(.day))
}
