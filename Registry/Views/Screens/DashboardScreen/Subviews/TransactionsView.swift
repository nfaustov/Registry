//
//  TransactionsView.swift
//  Registry
//
//  Created by Николай Фаустов on 25.06.2024.
//

import SwiftUI
import SwiftData

struct TransactionsView: View {
    //MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    @Query private var accounts: [CheckingAccount]

    // MARK: -

    var body: some View {
        NavigationStack {
            Form {
                ForEach(dates, id: \.self) { date in
                    Section {
                        ForEach(dateTransactions(date)) { transaction in
                            transactionView(transaction)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        transaction.account = nil
                                        modelContext.delete(transaction)
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
            .sheetToolbar("Все транзакции")
        }
    }
}

#Preview {
    TransactionsView()
}

// MARK: - Subviews

private extension TransactionsView {
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

private extension TransactionsView {
    var transactionsByDate: [Date: [AccountTransaction]] {
        let transactions = accounts.flatMap { $0.transactions }
        return Dictionary(grouping: transactions, by: { Calendar.current.startOfDay(for: $0.date) })
    }

    var dates: [Date] {
        Array(transactionsByDate.keys.sorted(by: >))
    }

    func dateTransactions(_ date: Date) -> [AccountTransaction] {
        transactionsByDate[date]?.sorted(by: { $0.date > $1.date }) ?? []
    }
}
