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

    init(date: Date, description: String, value: Double, kind: PatientMoneyTransaction.Kind, refunded: Bool) {
        id = UUID()
        self.date = date
        self.description = description
        self.value = value
        self.kind = kind
        self.refunded = refunded
    }

    init(payment: Payment) {
        id = UUID()
        date = payment.date
        description = payment.purpose.descripiton
        value = payment.methods.reduce(0.0) { $0 + $1.value }

        if value > 0 {
            kind = .toBalance
        } else {
            kind = .fromBalance
        }

        refunded = false
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
