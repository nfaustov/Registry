//
//  AccountsView.swift
//  Registry
//
//  Created by Николай Фаустов on 15.06.2024.
//

import SwiftUI
import SwiftData

struct AccountsView: View {
    // MARK: - Dependencies

    @Query private var accounts: [CheckingAccount]

    // MARK: -

    var body: some View {
        HStack {
            ForEach(accounts) { account in
                HStack {
                    accountImage(account)

                    VStack {
                        Text(account.title)
                        CurrencyText(account.balance)
                    }
                }
            }
        }
    }
}

#Preview {
    AccountsView()
}

// MARK: - Subviews

private extension AccountsView {
    func accountImage(_ account: CheckingAccount) -> some View {
        switch account.type {
        case .cash: Image(systemName: "")
        case .card: Image(systemName: "")
        case .bank: Image(systemName: "")
        case .credit: Image(systemName: "")
        }
    }
}
