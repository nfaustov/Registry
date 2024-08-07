//
//  PaymentsView.swift
//  Registry
//
//  Created by Николай Фаустов on 21.02.2024.
//

import SwiftUI
import SwiftData

struct PaymentsView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    let payments: [Payment]

    // MARK: - State

    @State private var selectedPayment: Payment? = nil
    @State private var operationType: OperationType = .all

    var body: some View {
        VStack {
            Text("Последние операции")
                .font(.headline)
                .padding(24)

            VStack(spacing: 0) {
                Picker("Тип операций", selection: $operationType) {
                    ForEach(OperationType.allCases, id: \.self) { type in
                        Text(type.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: operationType) {
                    selectedPayment = nil
                }
                .padding()

                Divider()
                    .padding(.horizontal)

                List {
                    ForEach(filteredPayments.sorted(by: { $0.date > $1.date })) { payment in
                        paymentRow(payment)
                            .padding(8)
                            .background(selectedPayment == payment ? Color(.tertiarySystemFill) : .clear)
                            .listRowSeparator(.hidden)
                            .cornerRadius(16)
                            .background(Color(.secondarySystemGroupedBackground))
                            .listRowBackground(Color(.secondarySystemGroupedBackground))
                            .onTapGesture {
                                if selectedPayment == payment {
                                    selectedPayment = nil
                                } else {
                                    selectedPayment = payment
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .scrollBounceBehavior(.basedOnSize)

                if let selectedPayment {
                    PaymentDetailView(
                        payment: selectedPayment,
                        onDelete: {
                            let ledger = Ledger(modelContext: modelContext)
                            ledger.cancelPayment(payment: selectedPayment)
                            self.selectedPayment = nil
                        }
                    )
                    .padding([.horizontal, .bottom])
                }
            }
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(16)
        }
    }
}

#Preview {
    PaymentsView(payments: [])
}

// MARK: - Subviews

private extension PaymentsView {
    func paymentRow(_ payment: Payment) -> some View {
        HStack(spacing: 16) {
            Image(systemName: payment.totalAmount >= 0 ? "arrow.left" : "arrow.right")
                .padding()
                .background(payment.totalAmount >= 0 ? .blue.opacity(0.1) : payment.purpose == .collection ? .purple.opacity(0.1) : .red.opacity(0.1))
                .cornerRadius(12)

            VStack(alignment: .leading) {
                Text(payment.purpose?.rawValue ?? "")
                    .font(.headline)
                Text(payment.details)
                    .font(.subheadline)
            }

            Spacer()

            CurrencyText(payment.totalAmount)
                .foregroundColor(payment.totalAmount >= 0 ? .primary : payment.purpose == .collection ? .purple : .red)
        }
    }
}

// MARK: - Calculations

private extension PaymentsView {
    enum OperationType: String, Hashable, CaseIterable {
        case all = "Все"
        case bills = "Счета"
        case spendings = "Расходы"
        case collections = "Инкассация"
    }

    var filteredPayments: [Payment] {
        switch operationType {
        case .all: return payments
        case .bills: return payments.filter { $0.subject != nil }
        case .spendings: return payments.filter { $0.totalAmount < 0 && $0.purpose != .collection }
        case .collections: return payments.filter { $0.purpose == .collection }
        }
    }
}
