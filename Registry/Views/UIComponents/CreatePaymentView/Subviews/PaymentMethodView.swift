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
        Section {
            if let additionalPaymentMethod {
                LabeledContent(paymentMethod.type.rawValue) {
                    textField(type: paymentMethod.type)
                        .onChange(of: paymentMethod.value) { _, newValue in
                            if let billTotalPrice = paymentKind.billTotalPrice {
                                self.additionalPaymentMethod?.value = billTotalPrice - account.balance - newValue
                            } else {
                                self.additionalPaymentMethod?.value = account.balance - newValue
                            }
                        }
                }

                LabeledContent(additionalPaymentMethod.type.rawValue) {
                    textField(type: additionalPaymentMethod.type)
                        .onChange(of: self.additionalPaymentMethod?.value ?? 0) { _, newValue in
                            if let billTotalPrice = paymentKind.billTotalPrice {
                                paymentMethod.value = billTotalPrice - account.balance - newValue
                            } else {
                                paymentMethod.value = account.balance - newValue
                            }
                        }
                }
            } else {
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
        } header: {
            HStack {
                Text("Способ оплаты")

                if additionalPaymentMethod != nil {
                    Spacer()
                    Button {
                        withAnimation {
                            additionalPaymentMethod = nil

                            if let billTotalPrice = paymentKind.billTotalPrice {
                                paymentMethod.value = billTotalPrice - account.balance
                            } else {
                                paymentMethod.value = account.balance
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.uturn.left")
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

// MARK: - Subviews

private extension PaymentMethodView {
    func textField(type: PaymentType) -> some View {
        TextField(
            type.rawValue,
            value: type == paymentMethod.type ?
                $paymentMethod.value :
                Binding(
                    get: { additionalPaymentMethod?.value ?? 0 },
                    set: { additionalPaymentMethod?.value = $0 }
                ),
            format: .number
        )
        .frame(width: 160)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.quaternarySystemFill))
        .clipShape(.rect(cornerRadius: 8, style: .continuous))
    }
}
