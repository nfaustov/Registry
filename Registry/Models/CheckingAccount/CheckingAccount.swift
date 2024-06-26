//
//  CheckingAccount.swift
//  Registry
//
//  Created by Николай Фаустов on 13.06.2024.
//

import Foundation
import SwiftData

@Model
final class CheckingAccount {
    var title: String
    let type: AccountType
    private(set) var balance: Double
    @Relationship(deleteRule: .cascade, inverse: \AccountTransaction.account)
    private var _transactions: [AccountTransaction]?

    var transactions: [AccountTransaction] {
        _transactions ?? []
    }

    init(title: String, type: AccountType, balance: Double, transactions: [AccountTransaction]? = []) {
        self.title = title
        self.type = type
        self.balance = balance
        _transactions = transactions
    }

    func assignTransaction(_ transaction: AccountTransaction) {
        _transactions?.append(transaction)
        balance += transaction.amount
    }

    func removeTransaction(_ transaction: AccountTransaction) {
        _transactions?.removeAll(where: { $0.id == transaction.id })
        balance -= transaction.amount
    }
}

enum AccountType: Codable, Hashable, CaseIterable {
    case cash
    case card
    case bank
    case credit

    var title: String {
        switch self {
        case .cash: return "Наличные"
        case .card: return "Карта"
        case .bank: return "Расчетный счет"
        case .credit: return "Кредитная линия"
        }
    }

    static func correlatedAccount(with paymentType: PaymentType) -> AccountType {
        switch paymentType {
        case .cash:
            return .cash
        case .bank:
            return .bank
        case .card:
            return .card
        }
    }
}
