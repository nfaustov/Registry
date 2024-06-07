//
//  ReportingView.swift
//  Registry
//
//  Created by Николай Фаустов on 06.06.2024.
//

import SwiftUI

struct ReportingView<Content: View>: View {
    // MARK: - Dependencies

    let title: String
    let content: () -> Content

    // MARK: - State

    @Binding private var date: Date
    @Binding private var selectedPeriod: StatisticsPeriod

    // MARK: -

    init(_ title: String,for date: Binding<Date>, selectedPeriod: Binding<StatisticsPeriod>, content: @escaping () -> Content) {
        self.title = title
        _date = date
        _selectedPeriod = selectedPeriod
        self.content = content
    }

    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.title3)
                DatePicker("", selection: $date, displayedComponents: .date)
                Picker("Выбранный период", selection: $selectedPeriod) {
                    ForEach(StatisticsPeriod.allCases) { period in
                        Text(period.rawValue)
                    }
                }
                .pickerStyle(.menu)
                .tint(.secondary)
                .frame(width: 100, alignment: .trailing)
            }

            content()
                .animation(.spring(), value: selectedPeriod)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
        .padding(4)
    }
}

#Preview {
    ReportingView("", for: .constant(.now), selectedPeriod: .constant(.day)) { Form { } }
}
