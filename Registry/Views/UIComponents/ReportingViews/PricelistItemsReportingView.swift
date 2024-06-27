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

    let date: Date
    let selectedPeriod: StatisticsPeriod

    // MARK: -

    var body: some View {
        GroupBox("Услуги") {
            if pricelistItemsUsage.isEmpty {
                ContentUnavailableView("Нет данных", systemImage: "tray")
            } else {
                ScrollView(.vertical) {
                    ForEach(pricelistItemsUsage, id: \.self) { usage in
                        LabeledContent {
                            Text("\(usage.count)")
                                .fontWeight(.medium)
                        } label: {
                            Text(usage.item.title)
                                .font(.footnote)
                        }
                        .padding(10)
                        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                .scrollIndicators(.hidden)
            }
        }
        .groupBoxStyle(.reporting)
    }
}

#Preview {
    PricelistItemsReportingView(date: .now, selectedPeriod: .day)
}

// MARK: - Calculation

private extension PricelistItemsReportingView {
    @MainActor
    var pricelistItemsUsage: [PricelistItemCount] {
        let ledger = Ledger(modelContext: modelContext)
        return ledger.topPricelistItemsByUsage(for: date, period: selectedPeriod, maxCount: 10)
    }
}
