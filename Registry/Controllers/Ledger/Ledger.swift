//
//  Ledger.swift
//  Registry
//
//  Created by Николай Фаустов on 21.02.2024.
//

import Foundation
import SwiftData

@MainActor
final class Ledger {
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func getReport(forDate date: Date = .now) -> Report? {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = startOfDay.addingTimeInterval(86_400)
        let predicate = #Predicate<Report> { $0.date > startOfDay && $0.date < endOfDay && !$0.closed }
        var descriptor = FetchDescriptor<Report>(predicate: predicate)
        descriptor.fetchLimit = 1

        return try? modelContext.fetch(descriptor).first
    }

    func createReport(with payment: Payment? = nil) {
        let report = Report(date: .now, startingCash: lastReport?.cashBalance ?? 0)

        if let payment { report.makePayment(payment) }

        modelContext.insert(report)
    }

    func closeReport() {
        guard let report = getReport() else { return }

        makeIncomeTransactions(from: report)
        makeExpenseTransactions(from: report)
        report.close()
        rewardDoctors()
    }
}

private extension Ledger {
    private var lastReport: Report? {
        var descriptor = FetchDescriptor<Report>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first
    }

    func checkingAccount(ofType type: AccountType) -> CheckingAccount? {
        let descriptor = FetchDescriptor<CheckingAccount>()
        
        if let account = try? modelContext.fetch(descriptor).first(where: { $0.type == type }) {
            return account
        } else { return nil }
    }

    func makeIncomeTransactions(from report: Report) {
        for type in PaymentType.allCases where type != .cash {
            let accountType = AccountType.correlatedAccount(with: type)

            guard let account = checkingAccount(ofType: accountType) else { return }

            let typeIncome = report.billsIncome(of: type)
            let transaction = AccountTransaction(purpose: .income, amount: typeIncome)
            account.assignTransaction(transaction)
        }
    }

    func makeExpenseTransactions(from report: Report) {
        let expensePayments = report.payments?.filter { $0.totalAmount < 0 } ?? []
        let groupedPayments = Dictionary(grouping: expensePayments, by: { $0.purpose })

        for (purpose, payments) in groupedPayments {
            if purpose == .collection {
                let amount = payments
                    .flatMap { $0.methods }
                    .reduce(0.0) { $0 + $1.value }
                let transaction = AccountTransaction(purpose: .transferFrom, detail: "Касса", amount: -amount)

                guard let account = checkingAccount(ofType: .cash) else { return }

                account.assignTransaction(transaction)
            } else {
                if let accountTransactionPurpose = purpose?.convertToAccountTransactionPurpose() {
                    for payment in payments {
                        for method in payment.methods {
                            guard let account = checkingAccount(ofType: AccountType.correlatedAccount(with: method.type)) else { return }

                            let transaction = AccountTransaction(purpose: accountTransactionPurpose, detail: payment.details, amount: method.value)
                            account.assignTransaction(transaction)
                        }
                    }
                }
            }
        }
    }

    func rewardDoctors() {
        if let endOfMonth = Calendar.current.dateInterval(of: .month, for: .now)?.end,
           Calendar.current.isDate(.now, inSameDayAs: endOfMonth),
           let topRegistrar = registrarActivity(for: .now, period: .month).first?.registrar {
            let achievement = Doctor.Achievement(type: .registrarOFMonth, icon: "star.square", period: DateFormat.monthYear.string(from: .now))
            topRegistrar.achievements.append(achievement)
        }
    }
}
