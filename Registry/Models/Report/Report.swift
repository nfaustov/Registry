//
//  Report.swift
//  Registry
//
//  Created by Николай Фаустов on 21.02.2024.
//

import Foundation
import SwiftData

@Model
public final class Report {
    public let id: UUID = UUID()
    public let date: Date = Date.now
    public let startingCash: Double = Double.zero
    public var payments: [Payment] = []

    public init(
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

    public var cashBalance: Double {
        startingCash + reporting(.profit, of: .cash) + collected
    }

    public var collected: Double {
        payments
            .filter { $0.purpose == .collection }
            .flatMap { $0.methods }
            .reduce(0.0) { $0 + $1.value }
    }

    public var hasBillIncome: Bool {
        !payments
            .compactMap { $0.subject }
            .isEmpty
    }

    public var hasOtherIncome: Bool {
        !payments
            .filter { $0.subject == nil }
            .flatMap { $0.methods }
            .filter { $0.value > 0 }
            .isEmpty
    }

    public var hasExpense: Bool {
        !payments
            .filter { $0.subject == nil }
            .filter { $0.purpose != .collection }
            .flatMap { $0.methods }
            .filter { $0.value < 0 }
            .isEmpty
    }

    public func billsIncome(of type: PaymentType) -> Double {
        payments
            .filter { $0.subject != nil }
            .flatMap { $0.methods }
            .filter { $0.type == type }
            .reduce(0.0) { $0 + $1.value }
    }

    public func othersIncome(of type: PaymentType? = nil) -> Double {
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

    public func reporting(_ reporting: Reporting, of type: PaymentType? = nil) -> Double {
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

    public func fraction(_ kind: Reporting, ofAccount type: PaymentType) -> Double {
        guard reporting(kind) != 0 else { return 0 }
        return reporting(kind, of: type) / reporting(kind)
    }

    public func updatePayment(for updatedBill: Bill) {
        guard let payment = payments
            .filter({ payment in
                switch payment.subject {
                case .bill(let bill): return bill.id == updatedBill.id
                default: return false
                }
            }).first else { return }

        guard let paymentIndex = payments.firstIndex(of: payment) else { return }

        var newPayment = payments.remove(at: paymentIndex)
        newPayment.subject = .bill(updatedBill)
        payments.append(newPayment)
    }

    public func replacePayment(with newPayment: Payment) {
        guard let paymentIndex = payments.firstIndex(where: { $0.id == newPayment.id }) else { return }

        payments.remove(at: paymentIndex)
        payments.append(newPayment)
    }
}

// MARK: - Reporting

public enum Reporting: String, Hashable, Identifiable, CaseIterable {
    case profit = "Баланс"
    case income = "Доходы"
    case expense = "Расходы"

    public var id: Self {
        self
    }
}

// MARK: - Salary calculation

public extension Report {
    func renderedServices(by employee: Employee, role: KeyPath<RenderedService, AnyEmployee?>) -> [RenderedService] {
        payments
            .compactMap { $0.subject }
            .filter { !$0.isRefund }
            .flatMap { $0.services }
            .filter { $0[keyPath: role]?.id == employee.id }
    }

    func refundedServices(by employee: Employee, role: KeyPath<RenderedService, AnyEmployee?>) -> [RenderedService] {
        payments
            .compactMap { $0.subject }
            .filter { $0.isRefund }
            .flatMap { $0.services }
            .filter { $0[keyPath: role]?.id == employee.id }
    }

    func employeeSalary(_ employee: Employee, from services: [RenderedService]) -> Double {
        switch employee.salary {
        case .pieceRate(let rate):
            return pieceRateSalary(rate, from: services) - pieceRateSalary(rate, from: refundedServices(by: employee, role: \.performer))
        default: return 0
        }
    }
}

// MARK: - Private methods

private extension Report {
    func paymentMethods(ofType type: PaymentType?) -> [Payment.Method] {
        let methods = payments
            .filter { $0.purpose != .collection }
            .flatMap { $0.methods }

        if let type { return methods.filter { $0.type == type } }

        return methods
    }

    func pieceRateSalary(_ rate: Double, from services: [RenderedService]) -> Double {
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
