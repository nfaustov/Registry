//
//  PricelistItemsReportingView.swift
//  Registry
//
//  Created by Николай Фаустов on 07.06.2024.
//

import SwiftUI

struct PricelistItemsReportingView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    // MARK: - State

    @State private var date: Date = .now
    @State private var selectedPeriod: StatisticsPeriod = .day

    // MARK: -

    var body: some View {
        ReportingView("Услуги", for: $date, selectedPeriod: $selectedPeriod) {
            List(Array(pricelistItemsUsage), id: \.self) { usage in
                LabeledContent(usage.item.title, value: "\(usage.count)")
            }
            .listStyle(.plain)
        }
    }
}

#Preview {
    PricelistItemsReportingView()
}

// MARK: - Calculation

private extension PricelistItemsReportingView {
    @MainActor
    var pricelistItemsUsage: [PricelistItemCount] {
        let ledger = Ledger(modelContext: modelContext)
        return ledger.topPricelistItemsByUsage(for: date, period: selectedPeriod, maxCount: 5)
    }
}
