//
//  Ledger.swift
//  Registry
//
//  Created by Николай Фаустов on 21.02.2024.
//

import SwiftUI

//public final class Ledger{
//    private var reports: [Report]
//
//    public init(reports: [Report]) {
//        self.reports = reports
//    }
//}

// MARK: - Statistic methods

//public extension Ledger {
//    func reporting(_ reporting: Reporting, of type: PaymentType? = nil) -> Double {
//        reports
//            .map { $0.reporting(reporting, of: type) }
//            .reduce(0.0, +)
//    }
//
//    func incomeFraction(ofAccount type: PaymentType) -> Double {
//        guard reporting(.income) > 0 else { return 0 }
//        return reporting(.income, of: type) / reporting(.income)
//    }
//
//    func pricelistItemUsage(id: String, period: DateInterval) -> Int {
//        servicesWithPricelistItem(id: id, period: period).count
//    }
//
//    func pricelistItemIncome(id: String, period: DateInterval) -> Double {
//        servicesWithPricelistItem(id: id, period: period)
//            .map { $0.pricelistItem.price }
//            .reduce(0.0, +)
//    }
//
//    func pricelistItemProfit(id: String, period: DateInterval) -> Double {
//        var servicesCostPrice = 0.0
//        var salaryForServices = 0.0
//
//        for service in servicesWithPricelistItem(id: id, period: period) {
//            switch service.performer?.salary {
//            case let .pieceRate(rate):
//                salaryForServices += service.pricelistItem.price * rate
//            case let .perService(amount):
//                salaryForServices += Double(amount)
//            default:()
//            }
//
//            if service.agent != nil {
//                salaryForServices += service.pricelistItem.price * 0.1
//            }
//
//            servicesCostPrice += service.pricelistItem.costPrice
//        }
//
//        let spendings = salaryForServices + servicesCostPrice + discountForPricelistItem(id: id, period: period)
//
//        return pricelistItemIncome(id: id, period: period) - spendings
//    }
//}

// MARK: - Private methods

//private extension Ledger {
//    func billsCollection(period: DateInterval) -> [AnyScoringItem] {
//        reports
//            .filter { $0.date > period.start && $0.date < period.end}
//            .flatMap { $0.payments }
//            .filter { $0.totalAmount > 0 }
//            .compactMap { $0.scoringItem }
//    }
//
//    func refundsCollection(period: DateInterval) -> [AnyScoringItem] {
//        reports
//            .filter { $0.date > period.start && $0.date < period.end}
//            .flatMap { $0.payments }
//            .filter { $0.totalAmount < 0 }
//            .compactMap { $0.scoringItem }
//    }
//
//    func discountForPricelistItem(id: String, period: DateInterval) -> Double {
//        billsCollection(period: period)
//            .filter { $0.services.contains(where: { $0.pricelistItem.id == id }) }
//            .map { $0.discount }
//            .reduce(0.0, +)
//    }
//
//    func servicesWithPricelistItem(id: String, period: DateInterval) -> [RenderedService] {
//        billsCollection(period: period)
//            .flatMap { $0.services }
//            .filter { $0.pricelistItem.id == id }
//    }
//}
