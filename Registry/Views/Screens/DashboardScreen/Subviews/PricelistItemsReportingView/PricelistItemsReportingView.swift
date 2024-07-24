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

    @State private var selectedCategory: Department?

    // MARK: -

    var body: some View {
        GroupBox {
            if categoriesRevenue.isEmpty {
                ContentUnavailableView("Нет данных", systemImage: "tray")
            } else {
                ScrollView(.vertical) {
                    ForEach(categoriesRevenue, id: \.self) { revenue in
                        Button {
                            selectedCategory = revenue.category
                        } label: {
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
                        .tint(.primary)
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                .scrollIndicators(.hidden)
            }
        } label: {
            Text("Категории услуг")
        }
        .groupBoxStyle(.reporting)
        .sheet(item: $selectedCategory) { category in
            NavigationStack {
                List(categoryTopServices(category), id: \.self) { usage in
                    LabeledContent {
                        Text("\(usage.count)")
                            .fontWeight(.medium)
                    } label: {
                        Text(usage.item.title)
                    }
                }
                .sheetToolbar(category.rawValue, subtitle: statisticPeriodLabel)
            }
        }
    }
}

#Preview {
    PricelistItemsReportingView(date: .now, selectedPeriod: .day)
}

// MARK: - Calculation

private extension PricelistItemsReportingView {
    var statisticPeriodLabel: String {
        if selectedPeriod == .day {
            return DateFormat.date.string(from: date)
        } else {
            let start = selectedPeriod.start(for: date)
            let end = selectedPeriod.end(for: date)

            return "\(DateFormat.date.string(from: start)) - \(DateFormat.date.string(from: end))"
        }
    }

    @MainActor
    var categoriesRevenue: [CategoryRevenue] {
        let ledger = Ledger(modelContext: modelContext)
        return ledger.categoriesRevenue(for: date, period: selectedPeriod)
    }

    @MainActor
    func categoryTopServices(_ category: Department) -> [PricelistItemCount] {
        let ledger = Ledger(modelContext: modelContext)
        return ledger.categoryTopServices(category, for: date, period: selectedPeriod, maxCount: 20)
    }
}
