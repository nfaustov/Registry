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
    let database: PersistentController

    init(modelContext: ModelContext) {
        database = DatabaseController(modelContext: modelContext)
    }

    func getReport(forDate date: Date = .now) -> Report? {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = startOfDay.addingTimeInterval(86_400)
        let predicate = #Predicate<Report> { $0.date > startOfDay && $0.date < endOfDay }

        return database.getModel(predicate: predicate)
    }

    func createReport(with payment: Payment? = nil) {
        let report = Report(date: .now, startingCash: lastReport?.cashBalance ?? 0)

        if let payment { report.makePayment(payment) }

        database.modelContext.insert(report)
    }

    func closeReport() {
        guard let report = getReport(), !report.closed else { return }

        makeTransfers(from: report)
        report.close()
        rewardDoctors()
    }
}

private extension Ledger {
    var lastReport: Report? {
        database.getModel(sortBy: [SortDescriptor(\.date, order: .reverse)])
    }

    func checkingAccount(ofType type: AccountType) -> CheckingAccount? {
        database.getModels().first(where: { $0.type == type })
    }

    func makeTransfers(from report: Report) {
        for type in PaymentType.allCases where type != .cash {
            let accountType = AccountType.correlatedAccount(with: type)

            guard let account = checkingAccount(ofType: accountType) else { return }

            let typeIncome = report.billsIncome(of: type)

            if typeIncome > 0 {
                let transaction = AccountTransaction(purpose: .transferFrom, detail: "Касса", amount: typeIncome)
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
