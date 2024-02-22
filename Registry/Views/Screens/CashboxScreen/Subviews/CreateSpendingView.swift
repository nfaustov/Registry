//
//  CreateSpendingView.swift
//  Registry
//
//  Created by Николай Фаустов on 22.02.2024.
//

import SwiftUI

struct CreateSpendingView: View {
    // MARK: - Dependencies

    @Bindable var report: Report

    // MARK: - State

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
                    Text("Назначение платежа")
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

                Section {
                    HStack {
                        TextField("Сумма оплаты", value: $paymentMethod.value, format: .number)
                        Spacer()
                        Image(systemName: "pencil")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Сумма оплаты")
                } footer: {
                    if paymentMethod.value > report.cashBalance {
                        Text("Недостаточно средств. В кассе \(Int(report.cashBalance)) ₽")
                            .foregroundStyle(.red)
                    }
                }
            }
            .sheetToolbar(
                title: "Списание средств",
                confirmationDisabled: paymentMethod.value == 0 || abs(paymentMethod.value) > report.cashBalance
            ) {
                paymentMethod.value = -abs(paymentMethod.value)
                let payment = Payment(purpose: paymentPurpose, methods: [paymentMethod])
                report.payments.append(payment)
            }
        }
    }
}

#Preview {
    CreateSpendingView(report: ExampleData.report)
}
