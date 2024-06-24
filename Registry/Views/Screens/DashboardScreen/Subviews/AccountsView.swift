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

//    @Query private var accounts: [CheckingAccount]
    let account = CheckingAccount(title: "Наличные", type: .cash, balance: 39_500)
    let account2 = CheckingAccount(title: "Карта", type: .card, balance: 45_800)
    let account3 = CheckingAccount(title: "Счет СБЕР", type: .bank, balance: 388_865.55)
    let account4 = CheckingAccount(title: "Кредитная линия", type: .credit, balance: -3_968_854.22)

    // MARK: -

    var body: some View {
        HStack(spacing: 4) {
            VStack(alignment: .leading) {
                Text("Баланс")
                    .font(.caption)
                CurrencyText(-3_158_435.34)
                    .font(.headline)
            }
            .padding(8)
            .frame(width: 152, alignment: .leading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            ForEach([account, account2, account3, account4]) { account in
                Button {
                    
                } label: {
                    VStack(alignment: .leading) {
                        HStack {
                            accountImage(account)
                            Text(account.title)
                                .font(.caption)
                        }

                        CurrencyText(account.balance)
                            .font(.headline)
                    }
                }
                .buttonStyle(AccountButtonStyle())
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
        case .cash: Image(systemName: "banknote")
        case .card: Image(systemName: "creditcard")
        case .bank: Image(systemName: "building.columns.circle")
        case .credit: Image(systemName: "rublesign.arrow.circlepath")
        }
    }
}

struct AccountButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(8)
            .frame(width: 160, alignment: .leading)
            .background(.blue.opacity(configuration.isPressed ? 0.5 : 0.1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .scaleEffect(configuration.isPressed ? 1.05 : 1)
            .foregroundStyle(.blue)
    }
}
