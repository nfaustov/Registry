//
//  PatientsReportingDetail.swift
//  Registry
//
//  Created by Николай Фаустов on 15.07.2024.
//

import SwiftUI

struct PatientsReportingDetail: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    // MARK: - State

    @State private var date: Date = .now

    // MARK: -

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Выберите дату", selection: $date, displayedComponents: .date)
                }

                Section {
                    VStack {
                        GroupBox("Посещаемость (квартал)") {
                            AttendanceChart(date: date, selectedPeriod: .month, chartType: .bar)
                                .padding()
                                .frame(height: 200)
                        }
                        .groupBoxStyle(.reporting)

                        GroupBox("Посещаемость (неделя)") {
                            AttendanceChart(date: date, selectedPeriod: .week, chartType: .bar)
                                .padding()
                                .frame(height: 200)
                        }
                        .groupBoxStyle(.reporting)
                    }
                }
            }
            .sheetToolbar("Статистика по пациентам")
        }
    }
}

#Preview {
    PatientsReportingDetail()
}
