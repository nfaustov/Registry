//
//  PatientTransactionsView.swift
//  Registry
//
//  Created by Николай Фаустов on 04.06.2024.
//

import SwiftUI

struct PatientTransactionsView: View {
    // MARK: - Dependencies

    let patient: Patient

    // MARK: - State

    @State private var transactions: [PatientMoneyTransaction] = []

    // MARK: -

    var body: some View {
        let transactionsByDate = Dictionary(grouping: transactions, by: { Calendar.current.startOfDay(for: $0.date) })
        let dates = Array(transactionsByDate.keys.sorted(by: >))

        Form {
            ForEach(dates, id: \.self) { date in
                Section {
                    let dateTransactionsOfKind = Dictionary(
                        grouping: transactionsByDate[date] ?? [],
                        by: { $0.kind }
                    )

                    transactionView(dateTransactionsOfKind, ofKind: .servicePayment)
                    transactionView(dateTransactionsOfKind, ofKind: .refund)
                    transactionView(dateTransactionsOfKind, ofKind: .toBalance)
                    transactionView(dateTransactionsOfKind, ofKind: .fromBalance)
                } header: {
                    DateText(date, format: .date)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .onAppear {
            transactions = patient.getTransactions(from: .distantPast)
        }
    }
}

#Preview {
    PatientTransactionsView(patient: ExampleData.patient)
}

// MARK: - Subviews

private extension PatientTransactionsView {
    @ViewBuilder func transactionView(
        _ transactions: [PatientMoneyTransaction.Kind: [PatientMoneyTransaction]],
        ofKind kind: PatientMoneyTransaction.Kind
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
            .clipShape(.rect(cornerRadius: 8, style: .continuous))
        }
    }

    func colorStyle(forTransactionOfKind kind: PatientMoneyTransaction.Kind) -> Color {
        switch kind {
        case .servicePayment:
                .mint
        case .refund:
                .pink
        case .toBalance:
                .blue
        case .fromBalance:
                .purple
        }
    }
}
