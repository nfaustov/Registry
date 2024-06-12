//
//  Ledger+Reporting.swift
//  Registry
//
//  Created by Николай Фаустов on 11.06.2024.
//

import Foundation
import SwiftData

extension Ledger {
    func income(for date: Date, period: StatisticsPeriod, of type: PaymentType? = nil) -> Double {
        let methods = getReports(for: date, period: period)
            .compactMap { $0.payments }
            .flatMap { $0 }
            .filter { $0.subject != nil }
            .flatMap { $0.methods }

        if let type {
            return methods
                .filter { $0.type == type }
                .reduce(0.0) { $0 + $1.value }
        } else {
            return methods.reduce(0.0) { $0 + $1.value }
        }
    }
}

private extension Ledger {
    func getReports(for date: Date, period: StatisticsPeriod) -> [Report] {
        let start = period.start(for: date)
        let end = period.end(for: date)
        let predicate = #Predicate<Report> { $0.date > start && $0.date < end }
        let descriptor = FetchDescriptor<Report>(predicate: predicate)

        if let reports = try? modelContext.fetch(descriptor) {
            return reports
        } else { return [] }
    }
}
