//
//  Ledger+AccountTransactions.swift
//  Registry
//
//  Created by Николай Фаустов on 14.06.2024.
//

import Foundation
import SwiftData

extension Ledger {
    func makeTransaction(
        purpose: AccountTransaction.Purpose,
        amount: Double,
        ofType accountType: AccountType
    ) {
        let account = checkingAccount(of: accountType)
        let transactionAmount = purpose == .income ? abs(amount) : -abs(amount)
        let transaction = AccountTransaction(purpose: purpose, amount: transactionAmount)
        account?.assignTransaction(transaction)
    }

    private func checkingAccount(of type: AccountType) -> CheckingAccount? {
        let predicate = #Predicate<CheckingAccount> { $0.type == type }
        var descriptor = FetchDescriptor<CheckingAccount>(predicate: predicate)
        descriptor.fetchLimit = 1

        if let account = try? modelContext.fetch(descriptor).first {
            return account
        } else { return nil }
    }
}
