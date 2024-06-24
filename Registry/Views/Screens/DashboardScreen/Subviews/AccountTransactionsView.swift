//
//  AccountTransactionsView.swift
//  Registry
//
//  Created by Николай Фаустов on 24.06.2024.
//

import SwiftUI

struct AccountTransactionsView: View {
    // MARK: - Dependencies

    let account: CheckingAccount

    // MARK: -

    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    HStack {
                        Text("Баланс:")
                        CurrencyText(account.balance)
                    }
                    .font(.headline)

                    Spacer()

                    Button {
                        
                    } label: {
                        Text("Приход")
                            .frame(width: 120)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        
                    } label: {
                        Text("Расход")
                            .frame(width: 120)
                    }
                    .buttonStyle(.borderedProminent)
                }

                ForEach(account.transactions) { transaction in
                    HStack(spacing: 16) {
                        Image(systemName: transaction.amount >= 0 ? "arrow.left" : "arrow.right")
                            .padding()
                            .background(transaction.amount >= 0 ? .blue.opacity(0.1) : .red.opacity(0.1))
                            .cornerRadius(12)

                        VStack(alignment: .leading) {
                            Text(transaction.purpose.title)
                                .font(.headline)
                            Text(transaction.purpose.description)
                                .font(.subheadline)
                        }

                        Spacer()

                        CurrencyText(transaction.amount)
                            .foregroundStyle(transaction.amount >= 0 ? .black : .red)
                    }
                }
                .onDelete(perform: account.removeTransactions)
            }
            .sheetToolbar(account.title)
        }
    }
}

#Preview {
    AccountTransactionsView(
        account: .init(
            title: "Наличные",
            type: .bank,
            balance: 39_500,
            transactions: [
                .init(purpose: .advertising("Сайт"), amount: 40_000),
                .init(purpose: .income, amount: 30_000)
            ]
        )
    )
}
