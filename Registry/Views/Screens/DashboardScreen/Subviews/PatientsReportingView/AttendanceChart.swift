//
//  AttendanceChart.swift
//  Registry
//
//  Created by Николай Фаустов on 07.07.2024.
//

import SwiftUI
import Charts

struct AttendanceChart: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    let date: Date
    let selectedPeriod: StatisticsPeriod

    // MARK: -

    var body: some View {
        LineAreaMarkChart(data: attendanceData, color: .indigo)
            .frame(height: 320)
    }
}

#Preview {
    AttendanceChart(date: .now, selectedPeriod: .week)
}

// MARK: - Calculation

private extension AttendanceChart {
    @MainActor
    var attendanceData: [DayIndicator] {
        let ledger = Ledger(modelContext: modelContext)
        return ledger.attendance(for: date, period: selectedPeriod)
    }
}
