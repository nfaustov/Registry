//
//  CreateSpendingView.swift
//  Registry
//
//  Created by Николай Фаустов on 22.02.2024.
//

import SwiftUI

struct CreateSpendingView: View {
    // MARK: - Dependencies

    @Environment(\.user) private var user
    @Environment(\.modelContext) private var modelContext

    let report: Report

    // MARK: - State

    @State private var cashBalance: Double = 0
    @State private var paymentMethod: Payment.Method = Payment.Method(.cash, value: 0)
    @State private var paymentPurpose: Payment.Purpose = .collection

    // MARK: -

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker(paymentPurpose.title, selection: $paymentPurpose) {
                        ForEach(Payment.Purpose.userSelectableCases, id: \.self) { purpose in
                            Text(purpose.title)
                        }
                    }

                    if paymentPurpose != .collection {
                        TextField("Описание", text: $paymentPurpose.descripiton)
                    }
                } header: {
                    Text("Назначение")
                }

                Section {
                    if paymentPurpose != .collection {
                        Picker(paymentMethod.type.rawValue, selection: $paymentMethod.type) {
                            ForEach(PaymentType.allCases, id: \.self) { type in
                                if type != .bank {
                                    Text(type.rawValue)
                                }
                            }
                        }
                    } else {
                        Text(paymentMethod.type.rawValue)
                    }
                } header: {
                    Text("Способ оплаты")
                }

                MoneyFieldSection("Сумма оплаты", value: $paymentMethod.value) {
                    if paymentMethod.value > cashBalance {
                        Text("Недостаточно средств. В кассе \(Int(cashBalance)) ₽")
                            .foregroundStyle(.red)
                    }
                }
            }
            .sheetToolbar(
                "Списание средств",
                disabled: paymentMethod.value == 0 || abs(paymentMethod.value) > cashBalance
            ) {
                let ledger = Ledger(modelContainer: modelContext.container)
                await ledger.makeSpendingPayment(purpose: paymentPurpose, method: paymentMethod, createdBy: user)
            }
        }
        .task {
            cashBalance = report.cashBalance
        }
    }
}

#Preview {
    CreateSpendingView(report: ExampleData.report)
}
