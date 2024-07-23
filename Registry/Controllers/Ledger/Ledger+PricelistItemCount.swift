//
//  Ledger+PricelistItemCount.swift
//  Registry
//
//  Created by Николай Фаустов on 07.06.2024.
//

import Foundation
import SwiftData

extension Ledger {
    func categoriesRevenue(for date: Date, period: StatisticsPeriod) -> [CategoryRevenue] {
        let services = billsCollection(date: date, period: period)
            .flatMap { $0.services }
        let groupedServices = Dictionary(grouping: services, by: { $0.pricelistItem.category })
        var categoriesRevenue: [CategoryRevenue] = []

        for (category, services) in groupedServices {
            let revenue = services.reduce(0.0) { partialResult, service in
                let discount = (service.check?.discountRate ?? 0) * service.price
                return partialResult + service.price - discount
            }

            if revenue > 0 {
                categoriesRevenue.append(CategoryRevenue(category: category, revenue: Int(revenue)))
            }
        }

        return categoriesRevenue
            .sorted(by: { $0.revenue > $1.revenue })
    }

    func categoryTopServices(
        _ category: Department,
        for date: Date,
        period: StatisticsPeriod,
        maxCount: Int
    ) -> [PricelistItemCount] {
        guard maxCount > 0 else { return [] }

        var pricelistItemUsage: [PricelistItemCount] = []

        let services = billsCollection(date: date, period: period)
            .flatMap { $0.services }
            .filter { $0.pricelistItem.category == category }
        let groupedServices = Dictionary(grouping: services, by: { $0.pricelistItem.id })
            .sorted(by: { $0.value.count > $1.value.count })
            .prefix(maxCount)

        for (id, services) in groupedServices {
            if let pricelistItem = getPricelistItem(by: id) {
                pricelistItemUsage.append(PricelistItemCount(item: pricelistItem, count: services.count))
            }
        }

        return pricelistItemUsage
    }
}

// MARK: - Private methods

private extension Ledger {
    func billsCollection(date: Date, period: StatisticsPeriod) -> [Check] {
        getChecks(forDate: date, period: period)
            .filter { $0.refund == nil }
    }

    func getPricelistItem(by pricelistItemID: String) -> PricelistItem? {
        let predicate = #Predicate<PricelistItem> { $0.id == pricelistItemID }
        return database.getModel(predicate: predicate)
    }

    func getChecks(forDate date: Date = .now, period: StatisticsPeriod) -> [Check] {
        let start = period.start(for: date)
        let end = period.end(for: date)
        let predicate = #Predicate<Payment> { $0.date > start && $0.date < end }

        return database.getModels(predicate: predicate).compactMap { $0.subject }
    }
}
