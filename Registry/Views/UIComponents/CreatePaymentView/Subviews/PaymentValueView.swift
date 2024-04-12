//
//  PaymentValueView.swift
//  Registry
//
//  Created by Николай Фаустов on 12.04.2024.
//

import SwiftUI

struct PaymentValueView<Footer: View>: View {
    // MARK: - Dependencies

    @Environment(\.paymentKind) private var paymentKind

    let account: Accountable

    @Binding var value: Double

    @ViewBuilder let footer: (Int) -> Footer

    // MARK: -

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
                footer(paymentBalance)
            }
        }
    }
}

#Preview {
    PaymentValueView(account: ExampleData.doctor, value: .constant(1500)) { _ in }
}

// MARK: - Calculations

private extension PaymentValueView {
    var paymentBalance: Int {
        switch paymentKind {
        case .balance:
            return Int(account.balance - value)
        case .bill(let totalPrice):
            return Int(account.balance + value - totalPrice)
        }
    }
}
