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
    let chartType: AttendanceChartType

    // MARK: -

    var body: some View {
        switch chartType {
        case .bar:
            BarMarkChart(data: attendanceData, color: .indigo)
        case .lineArea:
            LineAreaMarkChart(data: attendanceData, color: .indigo)
        }
    }
}

#Preview {
    AttendanceChart(date: .now, selectedPeriod: .week, chartType: .lineArea)
}

// MARK: - Calculation

private extension AttendanceChart {
    @MainActor
    var attendanceData: [DayIndicator] {
        let ledger = Ledger(modelContext: modelContext)
        return ledger.attendance(for: date, period: selectedPeriod)
    }
}

enum AttendanceChartType {
    case bar
    case lineArea
}
