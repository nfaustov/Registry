//
//  CreatePaymentView.swift
//  Registry
//
//  Created by Николай Фаустов on 12.04.2024.
//

import SwiftUI

struct CreatePaymentView: View {
    // MARK: - Dependencies

    @Environment(\.paymentKind) private var paymentKind

    let account: Accountable

    @Binding var paymentMethod: Payment.Method
    @Binding var additionalPaymentMethod: Payment.Method?

    // MARK: -

    var body: some View {
        Group {
            PaymentMethodView(
                account: account,
                paymentMethod: $paymentMethod,
                additionalPaymentMethod: $additionalPaymentMethod
            )
            .paymentKind(paymentKind)

            if additionalPaymentMethod == nil {
                PaymentValueView(account: account, value: $paymentMethod.value)
                    .paymentKind(paymentKind)
            }
        }
    }
}

#Preview {
    Form {
        CreatePaymentView(
            account: ExampleData.patient,
            paymentMethod: .constant(Payment.Method(.cash, value: 1000)),
            additionalPaymentMethod: .constant(Payment.Method(.card, value: 1500))
        )
        .paymentKind(.balance)
    }
}

// MARK: - PaymentKind

enum PaymentKind {
    case bill(totalPrice: Double)
    case balance

    var billTotalPrice: Double? {
        switch self {
        case .bill(let totalPrice):
            return totalPrice
        case .balance:
            return nil
        }
    }
}

private struct PaymentKindKey: EnvironmentKey {
    static var defaultValue: PaymentKind = .balance
}

extension EnvironmentValues {
    var paymentKind: PaymentKind {
        get { self[PaymentKindKey.self] }
        set { self[PaymentKindKey.self] = newValue }
    }
}

extension View {
    func paymentKind(_ kind: PaymentKind) -> some View {
        environment(\.paymentKind, kind)
    }
}
