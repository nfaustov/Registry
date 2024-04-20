//
//  Report.swift
//  Registry
//
//  Created by Николай Фаустов on 21.02.2024.
//

import Foundation
import SwiftData

extension RegistrySchemaV1 {
    @Model
    final class Report {
        let id: UUID = UUID()
        let date: Date = Date.now
        let startingCash: Double = Double.zero
        var payments: [Payment] = []

        init(
            id: UUID = UUID(),
            date: Date,
            startingCash: Double,
            payments: [Payment]
        ) {
            self.id = id
            self.date = date
            self.startingCash = startingCash
            self.payments = payments
        }

        var cashBalance: Double {
            startingCash + reporting(.profit, of: .cash) + collected
        }

        var collected: Double {
            payments
                .filter { $0.purpose == .collection }
                .flatMap { $0.methods }
                .reduce(0.0) { $0 + $1.value }
        }

        var hasBillIncome: Bool {
            !payments
                .compactMap { $0.subject }
                .isEmpty
        }

        var hasOtherIncome: Bool {
            !payments
                .filter { $0.subject == nil }
                .flatMap { $0.methods }
                .filter { $0.value > 0 }
                .isEmpty
        }

        var hasExpense: Bool {
            !payments
                .filter { $0.subject == nil }
                .filter { $0.purpose != .collection }
                .flatMap { $0.methods }
                .filter { $0.value < 0 }
                .isEmpty
        }

        func billsIncome(of type: PaymentType) -> Double {
            payments
                .filter { $0.subject != nil }
                .flatMap { $0.methods }
                .filter { $0.type == type }
                .reduce(0.0) { $0 + $1.value }
        }

        func othersIncome(of type: PaymentType? = nil) -> Double {
            let methods = payments
                .filter { $0.subject == nil }
                .flatMap { $0.methods }
                .filter { $0.value > 0 }

            if let type {
                return methods
                    .filter { $0.type == type }
                    .reduce(0.0) { $0 + $1.value }
            } else {
                return methods.reduce(0.0) { $0 + $1.value }
            }
        }

        func reporting(_ reporting: Reporting, of type: PaymentType? = nil) -> Double {
            switch reporting {
            case .profit:
                return paymentMethods(ofType: type).reduce(0.0) { $0 + $1.value }
            case .income:
                return paymentMethods(ofType: type)
                    .filter { $0.value > 0 }
                    .reduce(0.0) { $0 + $1.value }
            case .expense:
                return paymentMethods(ofType: type)
                    .filter { $0.value < 0 }
                    .reduce(0.0) { $0 + $1.value}
            }
        }

        func fraction(_ kind: Reporting, ofAccount type: PaymentType) -> Double {
            guard reporting(kind) != 0 else { return 0 }
            return reporting(kind, of: type) / reporting(kind)
        }

//        public func updatePayment(for updatedBill: Bill) {
//            guard let payment = payments
//                .filter({ payment in
//                    switch payment.subject {
//                    case .bill(let bill): return bill.id == updatedBill.id
//                    default: return false
//                    }
//                }).first else { return }
//
//            guard let paymentIndex = payments.firstIndex(of: payment) else { return }
//
//            var newPayment = payments.remove(at: paymentIndex)
//            newPayment.subject = .bill(updatedBill)
//            payments.append(newPayment)
//        }

        func replacePayment(with newPayment: Payment) {
            guard let paymentIndex = payments.firstIndex(where: { $0.id == newPayment.id }) else { return }

            payments.remove(at: paymentIndex)
            payments.append(newPayment)
        }

        func services(by employee: Employee, role: KeyPath<RenderedService, AnyEmployee?>) -> [RenderedService] {
            payments
                .compactMap { $0.subject }
                .flatMap { $0.services }
                .filter { $0[keyPath: role]?.id == employee.id }
        }

        func services(
            by employee: Employee,
            role: KeyPath<RenderedService, AnyEmployee?>,
            fromDate: Date
        ) -> [RenderedService] {
            payments
                .filter { $0.date > fromDate }
                .compactMap { $0.subject }
                .flatMap { $0.services }
                .filter { $0[keyPath: role]?.id == employee.id }
        }

        func employeeSalary(_ employee: Employee, from services: [RenderedService]) -> Double {
            switch employee.salary {
            case .pieceRate(let rate):
                return pieceRateSalary(rate, from: services)
            default: return 0
            }
        }

        private func paymentMethods(ofType type: PaymentType?) -> [RegistrySchemaV3.Payment.Method] {
            let methods = payments
                .filter { $0.purpose != .collection }
                .flatMap { $0.methods }

            if let type { return methods.filter { $0.type == type } }

            return methods
        }

        private func pieceRateSalary(_ rate: Double, from services: [RenderedService]) -> Double {
            services
                .reduce(0.0) { partialResult, service in
                    if service.pricelistItem.category == .laboratory {
                        partialResult + 0
                    } else if let fixedSalaryAmount = service.pricelistItem.salaryAmount {
                        partialResult + fixedSalaryAmount
                    } else {
                        partialResult + service.pricelistItem.price * rate
                    }
                }
        }
    }
}

extension RegistrySchemaV2 {
    @Model
    final class Report {
        let date: Date = Date.now
        let startingCash: Double = Double.zero
        @Relationship(deleteRule: .cascade, inverse: \Payment.report)
        private(set) var payments: [Payment]?

        init(
            date: Date,
            startingCash: Double,
            payments: [Payment]? = []
        ) {
            self.date = date
            self.startingCash = startingCash
            self.payments = payments
        }

//        var cashBalance: Double {
//            startingCash + reporting(.profit, of: .cash) + collected
//        }

        var collected: Double {
            payments?
                .filter { $0.purpose == .collection }
                .flatMap { $0.methods }
                .reduce(0.0) { $0 + $1.value } ?? 0
        }

        var hasBillIncome: Bool {
            guard let payments else { return false}

            return !payments
                .compactMap { $0.subject }
                .isEmpty
        }

        var hasOtherIncome: Bool {
            guard let payments else { return false}

            return !payments
                .filter { $0.subject == nil }
                .flatMap { $0.methods }
                .filter { $0.value > 0 }
                .isEmpty
        }

        var hasExpense: Bool {
            guard let payments else { return false}

            return !payments
                .filter { $0.subject == nil }
                .filter { $0.purpose != .collection }
                .flatMap { $0.methods }
                .filter { $0.value < 0 }
                .isEmpty
        }

        func billsIncome(of type: PaymentType) -> Double {
            payments?
                .filter { $0.subject != nil }
                .flatMap { $0.methods }
                .filter { $0.type == type }
                .reduce(0.0) { $0 + $1.value } ?? 0
        }

        func payment(_ payment: Payment) {
            payments?.append(payment)
        }

        func cancelPayment(_ paymentID: PersistentIdentifier) {
            payments?.removeAll(where: { $0.id == paymentID })
        }

        func othersIncome(of type: PaymentType? = nil) -> Double {
            let methods = payments?
                .filter { $0.subject == nil }
                .flatMap { $0.methods }
                .filter { $0.value > 0 } ?? []

            if let type {
                return methods
                    .filter { $0.type == type }
                    .reduce(0.0) { $0 + $1.value }
            } else {
                return methods.reduce(0.0) { $0 + $1.value }
            }
        }

//        func reporting(_ reporting: Reporting, of type: PaymentType? = nil) -> Double {
//            switch reporting {
//            case .profit:
//                return paymentMethods(ofType: type).reduce(0.0) { $0 + $1.value }
//            case .income:
//                return paymentMethods(ofType: type)
//                    .filter { $0.value > 0 }
//                    .reduce(0.0) { $0 + $1.value }
//            case .expense:
//                return paymentMethods(ofType: type)
//                    .filter { $0.value < 0 }
//                    .reduce(0.0) { $0 + $1.value}
//            }
//        }

//        func fraction(_ kind: Reporting, ofAccount type: PaymentType) -> Double {
//            guard reporting(kind) != 0 else { return 0 }
//            return reporting(kind, of: type) / reporting(kind)
//        }

//        func updatePayment(for updatedCheck: Check) {
//            guard let payment = payments?.first(where: { payment in
//                if let subject = payment.subject {
//                    return subject.id == updatedCheck.id
//                } else { return false }
//            }) else { return }
//
//            payment.subject = updatedCheck
//        }
    }
}

extension RegistrySchemaV3 {
    @Model
    final class Report {
        let date: Date = Date.now
        let startingCash: Double = Double.zero
        @Relationship(deleteRule: .cascade, inverse: \Payment.report)
        private(set) var payments: [Payment]?

        init(
            date: Date,
            startingCash: Double,
            payments: [Payment]? = []
        ) {
            self.date = date
            self.startingCash = startingCash
            self.payments = payments
        }

        var cashBalance: Double {
            startingCash + reporting(.profit, of: .cash) + collected
        }

        var collected: Double {
            payments?
                .filter { $0.purpose == .collection }
                .flatMap { $0.methods }
                .reduce(0.0) { $0 + $1.value } ?? 0
        }

        var hasBillIncome: Bool {
            guard let payments else { return false}

            return !payments
                .compactMap { $0.subject }
                .isEmpty
        }

        var hasOtherIncome: Bool {
            guard let payments else { return false}

            return !payments
                .filter { $0.subject == nil }
                .flatMap { $0.methods }
                .filter { $0.value > 0 }
                .isEmpty
        }

        var hasExpense: Bool {
            guard let payments else { return false}

            return !payments
                .filter { $0.subject == nil }
                .filter { $0.purpose != .collection }
                .flatMap { $0.methods }
                .filter { $0.value < 0 }
                .isEmpty
        }

        func billsIncome(of type: PaymentType) -> Double {
            payments?
                .filter { $0.subject != nil }
                .flatMap { $0.methods }
                .filter { $0.type == type }
                .reduce(0.0) { $0 + $1.value } ?? 0
        }

        func payment(_ payment: Payment) {
            payments?.append(payment)
        }

        func cancelPayment(_ paymentID: PersistentIdentifier) {
            payments?.removeAll(where: { $0.id == paymentID })
        }

        func othersIncome(of type: PaymentType? = nil) -> Double {
            let methods = payments?
                .filter { $0.subject == nil }
                .flatMap { $0.methods }
                .filter { $0.value > 0 } ?? []

            if let type {
                return methods
                    .filter { $0.type == type }
                    .reduce(0.0) { $0 + $1.value }
            } else {
                return methods.reduce(0.0) { $0 + $1.value }
            }
        }

        func reporting(_ reporting: Reporting, of type: PaymentType? = nil) -> Double {
            switch reporting {
            case .profit:
                return paymentMethods(ofType: type).reduce(0.0) { $0 + $1.value }
            case .income:
                return paymentMethods(ofType: type)
                    .filter { $0.value > 0 }
                    .reduce(0.0) { $0 + $1.value }
            case .expense:
                return paymentMethods(ofType: type)
                    .filter { $0.value < 0 }
                    .reduce(0.0) { $0 + $1.value}
            }
        }

        func fraction(_ kind: Reporting, ofAccount type: PaymentType) -> Double {
            guard reporting(kind) != 0 else { return 0 }
            return reporting(kind, of: type) / reporting(kind)
        }

        func updatePayment(for updatedCheck: Check) {
            guard let payment = payments?.first(where: { payment in
                if let subject = payment.subject {
                    return subject.id == updatedCheck.id
                } else { return false }
            }) else { return }

            payment.subject = updatedCheck
        }
    }
}

// MARK: - Reporting

enum Reporting: String, Hashable, Identifiable, CaseIterable {
    case profit = "Баланс"
    case income = "Доходы"
    case expense = "Расходы"

    var id: Self {
        self
    }
}

// MARK: - Private methods

private extension RegistrySchemaV3.Report {
    func paymentMethods(ofType type: PaymentType?) -> [Payment.Method] {
        let methods = payments?
            .filter { $0.purpose != .collection }
            .flatMap { $0.methods } ?? []

        if let type { return methods.filter { $0.type == type } }

        return methods
    }
}
