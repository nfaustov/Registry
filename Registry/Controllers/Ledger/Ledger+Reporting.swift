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
        cashboxIncome(for: date, period: period, of: type) + transactionsIncome(for: date, period: period, of: type)
    }

    func expense(for date: Date, period: StatisticsPeriod) -> [PurposeExpense] {
        var expenses: [PurposeExpense] = []
        let cashboxExpenses = cashboxExpense(for: date, period: period)
        let transactionExpenses = transactionsExpense(for: date, period: period)

        expenses.append(contentsOf: cashboxExpenses)
        expenses.append(contentsOf: transactionExpenses)

        let groupedExpenses = Dictionary(grouping: expenses, by: { $0.category })
            .map { PurposeExpense(category: $0, amount: $1.reduce(0.0) { $0 + $1.amount }) }

        return groupedExpenses
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

    func cashboxIncome(for date: Date, period: StatisticsPeriod, of type: PaymentType? = nil) -> Double {
        getReports(for: date, period: period).reduce(0.0) { $0 + $1.billsIncome(of: type) }
    }

    func cashboxExpense(for date: Date, period: StatisticsPeriod) -> [PurposeExpense] {
        var expenses: [PurposeExpense] = []

        let payments = getReports(for: date, period: period)
            .compactMap { $0.payments }
            .flatMap { $0 }
        let groupedPayments = Dictionary(grouping: payments, by: { $0.purpose })

        for (purpose, payments) in groupedPayments {
            if let category = purpose?.expenseCategory {
                let amount = payments.reduce(0.0) { $0 + $1.totalAmount }
                let purposeExpense = PurposeExpense(category: category, amount: amount)
                expenses.append(purposeExpense)
            }
        }

        return expenses
    }

    func transactionsIncome(for date: Date, period: StatisticsPeriod, of type: PaymentType? = nil) -> Double {
        let transactions = getTransactions(for: date, period: period)
            .filter { $0.purpose == .income }

        if let type {
            return transactions
                .filter { transaction in
                    if let account = transaction.account {
                        return account.type == AccountType.correlatedAccount(with: type)
                    } else {
                        return false
                    }
                }
                .reduce(0.0) { $0 + $1.amount }
        } else {
            return transactions.reduce(0.0) { $0 + $1.amount }
        }
    }

    func transactionsExpense(for date: Date, period: StatisticsPeriod) -> [PurposeExpense] {
        let transactions = getTransactions(for: date, period: period).filter { $0.amount < 0 }
        return Dictionary(grouping: transactions, by: { $0.purpose })
            .compactMap { purpose, transactions in
                if let expenseCategory = purpose.expenseCategory {
                    return PurposeExpense(category: expenseCategory, amount: transactions.reduce(0.0) { $0 + $1.amount })
                } else { return nil }
            }
    }
}
