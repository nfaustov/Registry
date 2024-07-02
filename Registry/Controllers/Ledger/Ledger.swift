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

            if typeIncome > 0 {
                let transaction = AccountTransaction(purpose: .income, amount: typeIncome)
                account.assignTransaction(transaction)
            }
        }
    }

    func rewardDoctors() {
        if let endOfMonth = Calendar.current.dateInterval(of: .month, for: .now)?.end,
           Calendar.current.isDate(.now, inSameDayAs: endOfMonth),
           let topRegistrar = registrarActivity(for: .now, period: .month).first?.registrar {
            let achievement = Doctor.Achievement(kind: .registrarOFMonth, period: DateFormat.monthYear.string(from: .now))
            topRegistrar.achievements.append(achievement)
        }
    }
}
