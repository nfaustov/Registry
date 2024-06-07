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

    private var lastReport: Report? {
        var descriptor = FetchDescriptor<Report>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first
    }

    func getReport(forDate date: Date = .now) -> Report? {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = startOfDay.addingTimeInterval(86_400)
        let predicate = #Predicate<Report> { $0.date > startOfDay && $0.date < endOfDay }
        var descriptor = FetchDescriptor<Report>(predicate: predicate)
        descriptor.fetchLimit = 1

        return try? modelContext.fetch(descriptor).first
    }

    func createReport(with payment: Payment? = nil) {
        let report = Report(date: .now, startingCash: lastReport?.cashBalance ?? 0)

        if let payment { report.makePayment(payment) }

        modelContext.insert(report)
    }
}
