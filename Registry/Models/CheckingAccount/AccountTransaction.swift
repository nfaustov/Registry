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
    let amount: Double

    var account: CheckingAccount?

    init(purpose: AccountTransaction.Purpose, amount: Double) {
        date = .now
        self.purpose = purpose
        self.amount = amount
    }
}
