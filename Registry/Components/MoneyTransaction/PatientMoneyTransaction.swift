//
//  PatientMoneyTransaction.swift
//  Registry
//
//  Created by Николай Фаустов on 07.05.2024.
//

import Foundation

struct PatientMoneyTransaction: MoneyTransaction, Hashable, Identifiable {
    let id: UUID
    let date: Date
    let description: String
    let value: Double
    let kind: PatientMoneyTransaction.Kind
    let refunded: Bool

    init(payment: Payment) {
        id = UUID()
        date = payment.date
        description = payment.details
        value = payment.methods.reduce(0.0) { $0 + $1.value }

        switch payment.purpose {
        case .medicalServices:
            kind = .servicePayment
            refunded = false
        case .refund:
            kind = .refund
            refunded = true
        case .toBalance:
            kind = .toBalance
            refunded = false
        case .fromBalance:
            kind = .fromBalance
            refunded = false
        default:
            kind = .servicePayment
            refunded = false
        }
    }
}

// MARK: - Kind

extension PatientMoneyTransaction {
    enum Kind: MoneyTransactionKind {
        case servicePayment
        case refund
        case toBalance
        case fromBalance

        var title: String {
            switch self {
            case .servicePayment:
                "Оплата услуг"
            case .refund:
                "Возврат"
            case .toBalance:
                "Пополнение"
            case .fromBalance:
                "Списание"
            }
        }
    }
}
