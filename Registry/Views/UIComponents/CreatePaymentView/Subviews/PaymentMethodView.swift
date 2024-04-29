//
//  PaymentMethodView.swift
//  Registry
//
//  Created by Николай Фаустов on 11.04.2024.
//

import SwiftUI

struct PaymentMethodView: View {
    // MARK: - Dependencies

    @Environment(\.paymentKind) private var paymentKind

    let account: Accountable

    @Binding var paymentMethod: Payment.Method
    @Binding var additionalPaymentMethod: Payment.Method?

    // MARK: -

    var body: some View {
        if let additionalPaymentMethod {
            MoneyFieldSection(paymentMethod.type.rawValue, value: $paymentMethod.value) {
                HStack {
                    Text("\(additionalPaymentMethod.type.rawValue) \(Int(additionalPaymentMethod.value)) ₽")

                    Spacer()

                    Button {
                        withAnimation {
                            self.additionalPaymentMethod = nil

                            if let billTotalPrice = paymentKind.billTotalPrice {
                                paymentMethod.value = billTotalPrice - account.balance
                            } else {
                                paymentMethod.value = account.balance
                            }
                        }
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .onChange(of: paymentMethod.value) { _, newValue in
                if let billTotalPrice = paymentKind.billTotalPrice {
                    self.additionalPaymentMethod?.value = billTotalPrice - account.balance - newValue
                } else {
                    self.additionalPaymentMethod?.value = account.balance - newValue
                }
            }
        } else {
            Section("Способ оплаты") {
                Picker(paymentMethod.type.rawValue, selection: $paymentMethod.type) {
                    ForEach(PaymentType.allCases, id: \.self) { type in
                        switch paymentKind {
                        case .balance:
                            if type != .bank {
                                Text(type.rawValue)
                            }
                        case .bill:
                            Text(type.rawValue)
                        }
                    }
                }
            }
        }
        
        if additionalPaymentMethod == nil {
            if let billTotalPrice = paymentKind.billTotalPrice {
                Menu("Добавить способ оплаты") {
                    ForEach(PaymentType.allCases, id: \.self) { type in
                        if type != paymentMethod.type {
                            Button(type.rawValue) {
                                withAnimation {
                                    additionalPaymentMethod = Payment.Method(type, value: 0)
                                    paymentMethod.value = billTotalPrice - account.balance
                                }
                            }
                        }
                    }
                }
            } else {
                Button("Добавить способ оплаты") {
                    withAnimation {
                        paymentMethod = Payment.Method(.cash, value: account.balance)
                        additionalPaymentMethod = Payment.Method(.card, value: 0)
                    }
                }
            }
        }
    }
}

#Preview {
    Form {
        PaymentMethodView(
            account: ExampleData.doctor,
            paymentMethod: .constant(Payment.Method(.cash, value: 1000)),
            additionalPaymentMethod: .constant(Payment.Method(.card, value: 1500))
        )
    }
}
