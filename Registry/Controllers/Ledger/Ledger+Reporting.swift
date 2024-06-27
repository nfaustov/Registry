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
//        let transactions = getTransactions(for: date, period: period)
//            .filter { $0.purpose == .income }
//
//        if let type {
//            return transactions
//                .filter { transaction in
//                    if let account = transaction.account {
//                        return account.type == AccountType.correlatedAccount(with: type)
//                    } else {
//                        return false
//                    }
//                }
//                .reduce(0.0) { $0 + $1.amount }
//        } else {
//            return transactions.reduce(0.0) { $0 + $1.amount }
//        }
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
        let transactions = getTransactions(for: date, period: period).filter { $0.amount < 0 }
        return Dictionary(grouping: transactions, by: { $0.purpose })
            .compactMap { purpose, transactions in
                if let expenseCategory = purpose.expenseCategory {
                    return PurposeExpense(category: expenseCategory, amount: transactions.reduce(0.0) { $0 + $1.amount })
                } else { return nil }
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

    func getTransactions(for date: Date, period: StatisticsPeriod) -> [AccountTransaction] {
        let start = period.start(for: date)
        let end = period.end(for: date)
        let predicate = #Predicate<AccountTransaction> { $0.date > start && $0.date < end }
        let descriptor = FetchDescriptor(predicate: predicate)

        if let transactions = try? modelContext.fetch(descriptor) {
            return transactions
        } else { return [] }
    }
}

struct PurposeExpense: Hashable {
    let category: ExpenseCategory
    var amount: Double
}

enum ExpenseCategory: String, CaseIterable {
    case dividends = "Дивиденды"
    case doctorPayout = "Выплаты врачам"
    case refund = "Возвраты"
    case laboratory = "Лаборатория"
    case equipment = "Оборудование"
    case consumables = "Расходники"
    case building = "Помещение"
    case taxes = "Налоги"
    case advertising = "Реклама"
    case loan = "Кредит"
    case banking = "Банковские услуги"
    case other = "Прочее"
}
