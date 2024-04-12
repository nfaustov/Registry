//
//  PaymentValueView.swift
//  Registry
//
//  Created by Николай Фаустов on 12.04.2024.
//

import SwiftUI

struct PaymentValueView: View {
    // MARK: - Dependencies

    let account: Accountable

    @Binding var value: Double

    var body: some View {
        Section {
            LabeledContent {
                Image(systemName: "pencil")
            } label: {
                TextField("Сумма выплаты", value: $value, format: .number)
            }
        } header: {
            Text("Сумма вылаты")
        } footer: {
            if paymentBalance != 0 {
                Text("Остаток на балансе: \(paymentBalance) ₽")
                    .foregroundColor(paymentBalance < 0 ? .red : .secondary)
            }
        }
    }
}

#Preview {
    PaymentValueView(account: ExampleData.doctor, value: .constant(1500))
}

// MARK: - Calculations

private extension PaymentValueView {
    var paymentBalance: Int {
        Int(account.balance - value)
    }
}
