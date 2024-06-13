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

    func expense(for date: Date, period: StatisticsPeriod) -> [PurposeExpense] {
        var expenses: [PurposeExpense] = []

        let payments = getReports(for: date, period: period)
            .compactMap { $0.payments }
            .flatMap { $0 }
            .filter { $0.totalAmount < 0 }
        let groupedPayments = Dictionary(grouping: payments, by: { $0.purpose })

        for (purpose, payments) in groupedPayments {
            var purposeExpense = PurposeExpense(purpose: purpose, amount: 0)

            for payment in payments {
                purposeExpense.amount += payment.totalAmount
            }

            expenses.append(purposeExpense)
        }

        return expenses
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

struct PurposeExpense: Hashable {
    let purpose: Payment.Purpose
    var amount: Double
}
