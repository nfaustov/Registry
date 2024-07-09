//
//  IncomeChart.swift
//  Registry
//
//  Created by Николай Фаустов on 07.07.2024.
//

import SwiftUI
import Charts

struct IncomeChart: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    let date: Date
    let selectedPeriod: StatisticsPeriod

    // MARK: -

    var body: some View {
        LineAreaMarkChart(data: incomeData, color: .blue)
            .frame(height: 100)
    }
}

#Preview {
    IncomeChart(date: .now, selectedPeriod: .week)
}

// MARK: - Calculation

private extension IncomeChart {
    @MainActor
    var incomeData: [DayIndicator] {
        let ledger = Ledger(modelContext: modelContext)
        return ledger.incomeByDays(for: date, period: selectedPeriod)
    }
}
