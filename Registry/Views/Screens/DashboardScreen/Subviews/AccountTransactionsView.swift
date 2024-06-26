//
//  AccountTransactionsView.swift
//  Registry
//
//  Created by Николай Фаустов on 24.06.2024.
//

import SwiftUI

struct AccountTransactionsView: View {
    // MARK: - Dependencies

    @EnvironmentObject private var coordinator: Coordinator

    let account: CheckingAccount

    // MARK: - State

    @State private var transactionKind: TransactionKind?

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
                        transactionKind = .income
                    } label: {
                        Text("Приход")
                            .frame(width: 120)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        transactionKind = .expense
                    } label: {
                        Text("Расход")
                            .frame(width: 120)
                    }
                    .buttonStyle(.borderedProminent)
                }

                ForEach(dates, id: \.self) { date in
                    Section {
                        ForEach(dateTransactions(date)) { transaction in
                            transactionView(transaction)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        account.removeTransaction(transaction)
                                    } label: {
                                        Label("Удалить", systemImage: "trash")
                                    }
                                }
                        }
                    } header: {
                        DateText(date, format: .date)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .sheetToolbar(account.title)
            .sheet(item: $transactionKind) { kind in
                CreateTransactionView(account: account, kind: kind)
            }
        }
    }
}

#Preview {
    AccountTransactionsView(
        account: .init(
            title: "Наличные",
            type: .bank,
            balance: 39_500
        )
    )
}

// MARK: - Subviews

private extension AccountTransactionsView {
    func transactionView(_ transaction: AccountTransaction) -> some View {
        HStack(spacing: 16) {
            Image(systemName: transaction.amount >= 0 ? "arrow.left" : "arrow.right")
                .padding()
                .background(transaction.amount >= 0 ? .blue.opacity(0.1) : .red.opacity(0.1))
                .cornerRadius(12)

            VStack(alignment: .leading) {
                Text(transaction.purpose.rawValue)
                    .font(.headline)
                Text(transaction.counterparty?.fullTitle ?? transaction.detail ?? "")
                    .font(.subheadline)
            }

            Spacer()

            CurrencyText(transaction.amount)
                .foregroundStyle(transaction.amount >= 0 ? .black : .red)
        }
    }
}

// MARK: - Calculations

private extension AccountTransactionsView {
    var transactionsByDate: [Date: [AccountTransaction]] {
        Dictionary(grouping: account.transactions, by: { Calendar.current.startOfDay(for: $0.date) })
    }

    var dates: [Date] {
        Array(transactionsByDate.keys.sorted(by: >))
    }

    func dateTransactions(_ date: Date) -> [AccountTransaction] {
        transactionsByDate[date]?.sorted(by: { $0.date > $1.date }) ?? []
    }
}
