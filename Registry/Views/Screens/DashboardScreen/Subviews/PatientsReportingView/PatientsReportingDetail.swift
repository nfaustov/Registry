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
        HStack(alignment: .top) {
            VStack {
                AttendanceChart(date: date, selectedPeriod: .month, chartType: .lineArea)
                    .padding()
                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .frame(height: 320)
                    .shadow(color: .black.opacity(0.05), radius: 3, y: 2)

                AttendanceChart(date: date, selectedPeriod: .week, chartType: .bar)
                    .padding()
                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .frame(height: 320)
                    .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
            }
            .padding()

            LabeledContent("Выберите дату") {
                DatePicker("", selection: $date, displayedComponents: .date)
            }
            .padding()
        }
    }
}

#Preview {
    PatientsReportingDetail()
}
