//
//  Ledger.swift
//  Registry
//
//  Created by Николай Фаустов on 21.02.2024.
//

import Foundation
import SwiftData

@ModelActor
actor Ledger {
    func proceedPayment(_ payment: Payment, as sample: PaymentFactory.Sample) {
        switch sample {
        case .medicalService:
            medicalServicePayment(payment)
        case .doctorPayout(let doctor, _):
            doctorPayoutPayment(payment, for: doctor)
        case .refund(let refund, _, let includeBalance):
            refundPayment(payment, refund: refund, includeBalance: includeBalance)
        case .balance(_, let person, _):
            balancePayment(payment, for: person)
        case .spending:
            spendingPayment(payment)
        }
    }

    func medicalServicePayment(_ payment: Payment) {
        guard let check = payment.subject,
              let patient = check.appointments?.first?.patient else { return }

        let paymentValue = payment.methods.reduce(0.0) { $0 + $1.value }
        let paymentBalance = paymentValue - check.totalPrice

        if paymentBalance != 0 {
            updateBalanceWithoutRecord(person: patient, increment: paymentBalance, createdBy: payment.createdBy)
        }

        patient.assignTransaction(payment)
        check.makeChargesForServices()
        check.appointments?.forEach { $0.status = .completed }
        record(payment)
    }

    func doctorPayoutPayment(_ payment: Payment, for doctor: Doctor) {
        let paymentValue = payment.methods.reduce(0.0) { $0 + $1.value }
        doctor.assignTransaction(payment)
        doctor.updateBalance(increment: paymentValue)
        record(payment)
    }

    func refundPayment(_ payment: Payment, refund: Refund, includeBalance: Bool) {
        guard let patient = refund.check?.appointments?.first?.patient else { return }

        if includeBalance, patient.balance != 0 {
            updateBalanceWithoutRecord(person: patient, increment: -patient.balance, createdBy: payment.createdBy)
        }

        patient.assignTransaction(payment)
        record(payment)
    }

    func balancePayment(_ payment: Payment, for person: AccountablePerson) {
        guard let paymentMethod = payment.methods.first else { return }

        person.assignTransaction(payment)
        person.updateBalance(increment: paymentMethod.value)
        record(payment)
    }

    func spendingPayment(_ payment: Payment) {
        record(payment)
    }

    func getReport(forDate date: Date = .now) -> Report? {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = startOfDay.addingTimeInterval(86_400)
        let predicate = #Predicate<Report> { $0.date > startOfDay && $0.date < endOfDay }
        var descriptor = FetchDescriptor<Report>(predicate: predicate)
        descriptor.fetchLimit = 1

        return try? modelContext.fetch(descriptor).first
    }

    func createReport() -> Report {
        if let todayReport {
            return todayReport
        } else {
            let report = Report(date: .now, startingCash: lastReport?.cashBalance ?? 0)
            modelContext.insert(report)
            try? modelContext.save()

            return report
        }
    }
}

// MARK: - Private methods

private extension Ledger {
    var lastReport: Report? {
        var descriptor = FetchDescriptor<Report>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first
    }

    var todayReport: Report? {
        guard let lastReport,
                Calendar.current.isDateInToday(lastReport.date) else { return nil }
        return lastReport
    }

    func record(_ payment: Payment) {
        if let todayReport {
            todayReport.makePayment(payment)
        } else {
            createReportWithPayment(payment)
        }

        try? modelContext.save()
    }

    func createReportWithPayment(_ payment: Payment) {
        let newReport = Report(date: .now, startingCash: lastReport?.cashBalance ?? 0, payments: [payment])
        modelContext.insert(newReport)
    }

    func updateBalanceWithoutRecord(person: AccountablePerson, increment: Double, createdBy user: User) {
        let balancePayment = Payment(purpose: .toBalance(person.initials), methods: [.init(.cash, value: increment)], createdBy: user.asAnyUser)
        person.updateBalance(increment: increment)
        person.assignTransaction(balancePayment)
    }
}

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
