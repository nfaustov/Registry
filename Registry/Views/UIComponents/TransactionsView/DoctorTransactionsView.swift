//
//  DoctorTransactionsView.swift
//  Registry
//
//  Created by Николай Фаустов on 06.05.2024.
//

import SwiftUI

struct DoctorTransactionsView: View {
    // MARK: - Dependencies

    let doctor: Doctor
    var balanceActionsEnabled: Bool = true

    // MARK: - State

    @State private var transactions: [DoctorMoneyTransaction] = []

    // MARK: -

    var body: some View {
        let transactionsByDate = Dictionary(grouping: transactions, by: { Calendar.current.startOfDay(for: $0.date) })
        let dates = Array(transactionsByDate.keys.sorted(by: >))

        Form {
            if balanceActionsEnabled {
                BalanceView(person: doctor)
            }

            ForEach(dates, id: \.self) { date in
                Section {
                    let dateTransactionsOfKind = Dictionary(
                        grouping: transactionsByDate[date] ?? [],
                        by: { $0.kind }
                    )

                    transactionView(dateTransactionsOfKind, ofKind: .payout)
                    transactionView(dateTransactionsOfKind, ofKind: .refill)
                    transactionView(dateTransactionsOfKind, ofKind: .performerFee)
                    transactionView(dateTransactionsOfKind, ofKind: .agentFee)
                } header: {
                    DateText(date, format: .date)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .onAppear {
            transactions = doctor.getTransactions(from: .distantPast)
        }
    }
}

#Preview {
    DoctorTransactionsView(doctor: ExampleData.doctor)
}

// MARK: - Subviews

private extension DoctorTransactionsView {
    @ViewBuilder func transactionView(
        _ transactions: [DoctorMoneyTransaction.Kind: [DoctorMoneyTransaction]],
        ofKind kind: DoctorMoneyTransaction.Kind
    ) -> some View {
        if let transactions = transactions[kind] {
            VStack(alignment: .leading, spacing: 0) {
                Text(kind.title)
                    .font(.headline)
                    .foregroundStyle(colorStyle(forTransactionOfKind: kind))
                    .padding(.bottom)
                ForEach(transactions) { transaction in
                    Divider()
                        .overlay(colorStyle(forTransactionOfKind: kind))
                        .padding(.vertical, 8)

                    LabeledCurrency(transaction.description, value: transaction.value)
                        .foregroundStyle(transaction.refunded ? .secondary : .primary)
                }
            }
            .padding()
            .background(colorStyle(forTransactionOfKind: kind).opacity(0.1))
            .clipShape(.rect(cornerRadius: 4, style: .continuous))
        }
    }

    func colorStyle(forTransactionOfKind kind: DoctorMoneyTransaction.Kind) -> Color {
        switch kind {
        case .agentFee:
                .mint
        case .performerFee:
                .cyan
        case .payout:
                .purple
        case .refill:
                .blue
        }
    }
}
