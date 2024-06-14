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
    private(set) var transactions: [AccountTransaction]?

    init(title: String, type: AccountType, balance: Double) {
        self.title = title
        self.type = type
        self.balance = balance
    }

    func assignTransaction(_ transaction: AccountTransaction) {
        transactions?.append(transaction)
        balance += transaction.amount
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
}
