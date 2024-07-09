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

    // MARK: - State

    @State private var reportingType: ReportingType = .pricelistItems

    // MARK: -

    var body: some View {
        GroupBox {
            if reportingType == .pricelistItems {
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
            } else if reportingType == .categories {
                if categoriesRevenue.isEmpty {
                    ContentUnavailableView("Нет данных", systemImage: "tray")
                } else {
                    ScrollView(.vertical) {
                        ForEach(categoriesRevenue, id: \.self) { revenue in
                            LabeledContent {
                                Text("\(revenue.revenue, format: .number)")
                                    .fontWeight(.medium)
                            } label: {
                                Text(revenue.category.rawValue)
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
        } label: {
            LabeledContent("Услуги") {
                Picker("", selection: $reportingType) {
                    ForEach(ReportingType.allCases, id: \.self) { type in
                        Text(type.rawValue)
                    }
                }
                .tint(.secondary)
            }
        }
        .groupBoxStyle(.reporting)
        .animation(.linear, value: reportingType)
    }
}

#Preview {
    PricelistItemsReportingView(date: .now, selectedPeriod: .day)
}

// MARK: - Calculation

private extension PricelistItemsReportingView {
    enum ReportingType: String, CaseIterable {
        case pricelistItems = "Услуги"
        case categories = "Категории"
    }

    @MainActor
    var pricelistItemsUsage: [PricelistItemCount] {
        let ledger = Ledger(modelContext: modelContext)
        return ledger.topPricelistItemsByUsage(for: date, period: selectedPeriod, maxCount: 10)
    }

    @MainActor
    var categoriesRevenue: [CategoryRevenue] {
        let ledger = Ledger(modelContext: modelContext)
        return ledger.categoriesRevenue(for: date, period: selectedPeriod)
    }
}
