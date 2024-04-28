//
//  PaymentValueView.swift
//  Registry
//
//  Created by Николай Фаустов on 12.04.2024.
//

import SwiftUI

struct PaymentValueView: View {
    // MARK: - Dependencies

    @Environment(\.paymentKind) private var paymentKind

    let account: Accountable

    @Binding var value: Double

    // MARK: -

    var body: some View {
        Section {
            LabeledContent {
                Image(systemName: "pencil")
            } label: {
                MoneyField(value: $value)
            }
        } header: {
            Text(textFieldTitle)
        } footer: {
            if finalAccountBalance != 0 {
                Text("Остаток на балансе: \(finalAccountBalance) ₽")
                    .foregroundColor(finalAccountBalance < 0 ? .red : .secondary)
            }
        }
    }
}

#Preview {
    PaymentValueView(account: ExampleData.doctor, value: .constant(1500))
}

// MARK: - Calculations

private extension PaymentValueView {
    var finalAccountBalance: Int {
        switch paymentKind {
        case .balance:
            return Int(account.balance - value)
        case .bill(let totalPrice):
            return Int(account.balance + value - totalPrice)
        }
    }

    var textFieldTitle: String {
        switch paymentKind {
        case .balance:
            return "Сумма выплаты"
        case .bill:
            return "Сумма оплаты"
        }
    }
}
