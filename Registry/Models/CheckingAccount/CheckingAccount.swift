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
    private(set) var cash: Double = Double.zero
    private(set) var bank: Double = Double.zero
    private(set) var card: Double = Double.zero
    private(set) var creditLine: Double = Double.zero

    init(cash: Double, bank: Double, card: Double, creditLine: Double) {
        self.cash = cash
        self.bank = bank
        self.card = card
        self.creditLine = creditLine
    }

    func updateBalance(by payment: Payment) {
        for method in payment.methods {
            switch method.type {
            case .cash:
                cash += method.value
            case .bank:
                bank += method.value
            case .card:
                card += method.value
            }
        }
    }

    func borrow(_ amount: Double) {
        creditLine -= amount
        bank +=  amount
    }

    func returnLoan(_ amount: Double) {
        creditLine += amount
        bank -= amount
    }
}
