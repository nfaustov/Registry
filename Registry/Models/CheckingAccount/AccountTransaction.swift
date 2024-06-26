//
//  AccountTransaction.swift
//  Registry
//
//  Created by Николай Фаустов on 14.06.2024.
//

import Foundation
import SwiftData

@Model
final class AccountTransaction {
    let date: Date = Date.now
    let purpose: AccountTransaction.Purpose
    let detail: String?
    let amount: Double
    @Relationship(inverse: \Counterparty.transactions)
    var counterparty: Counterparty?

    var account: CheckingAccount?

    init(
        purpose: AccountTransaction.Purpose,
        detail: String? = nil,
        amount: Double,
        counterparty: Counterparty? = nil
    ) {
        date = .now
        self.purpose = purpose
        self.detail = detail
        self.amount = amount
        self.counterparty = counterparty
    }
}
