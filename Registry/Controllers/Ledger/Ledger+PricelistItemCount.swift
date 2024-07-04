//
//  Ledger+PricelistItemCount.swift
//  Registry
//
//  Created by Николай Фаустов on 07.06.2024.
//

import Foundation
import SwiftData

extension Ledger {
    func topPricelistItemsByUsage(for date: Date, period: StatisticsPeriod, maxCount: Int) -> [PricelistItemCount] {
        guard maxCount > 0 else { return [] }

        var pricelistItemUsage: [PricelistItemCount] = []

        let services = billsCollection(date: date, period: period)
            .flatMap { $0.services }
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
