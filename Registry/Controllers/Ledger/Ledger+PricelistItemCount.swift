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
        var pricelistItemUsage: [PricelistItemCount] = []

        countServices(for: date, period: period, maxCount: maxCount).forEach {
            if let pricelistItem = getPricelistItem(by: $0.service.pricelistItem.id) {
                pricelistItemUsage.append(PricelistItemCount(item: pricelistItem, count: $0.count))
            }
        }

        return pricelistItemUsage
            .sorted(by: { $0.count > $1.count })
    }
}

// MARK: - Private methods

private extension Ledger {
    func billsCollection(date: Date, period: StatisticsPeriod) -> [Check] {
        getChecks(forDate: date, period: period)
            .filter { $0.refund == nil }
    }

    func refundsCollection(date: Date, period: StatisticsPeriod) -> [Refund] {
        getChecks(forDate: date, period: period)
            .compactMap { $0.refund }
    }

    func countServices(for date: Date, period: StatisticsPeriod, maxCount: Int) -> [ServiceCount] {
        guard maxCount > 0 else { return [] }

        let services = billsCollection(date: date, period: period)
            .flatMap { $0.services }
        let groupedServices = Dictionary(grouping: services, by: { $0.pricelistItem.id })
            .sorted(by: { $0.value.count > $1.value.count })
        let topFiveServices = groupedServices
            .prefix(maxCount)
            .compactMap { ServiceCount(service: $0.value.first!, count: $0.value.count) }

        return topFiveServices
    }

    func getPricelistItem(by pricelistItemID: String) -> PricelistItem? {
        let predicate = #Predicate<PricelistItem> { $0.id == pricelistItemID }
        var descriptor = FetchDescriptor<PricelistItem>(predicate: predicate)
        descriptor.fetchLimit = 1

        return try? modelContext.fetch(descriptor).first
    }

    func getChecks(forDate date: Date = .now, period: StatisticsPeriod) -> [Check] {
        let start = period.start(for: date)
        let end = period.end(for: date)
        let predicate = #Predicate<Payment> { $0.date > start && $0.date < end }
        let descriptor = FetchDescriptor<Payment>(predicate: predicate)

        if let payments = try? modelContext.fetch(descriptor) {
            return payments.compactMap { $0.subject }
        } else { return [] }
    }
}

struct ServiceCount {
    let service: MedicalService
    let count: Int
}

struct PricelistItemCount: Hashable {
    let item: PricelistItem
    let count: Int
}
