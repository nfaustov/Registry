//
//  PaymentDetailView.swift
//  Registry
//
//  Created by Николай Фаустов on 21.02.2024.
//

import SwiftUI

struct PaymentDetailView: View {
    // MARK: - Dependencies

    @Binding var payment: Payment

    var onDelete: () -> Void

    // MARK: -

    init(payment: Binding<Payment>, onDelete: @escaping () -> Void) {
        _payment = payment
        self.onDelete = onDelete
    }

    var body: some View {
        VStack(alignment: .leading) {
            Divider()
                .padding(.bottom)

            HStack {
                Text(payment.purpose.title)
                    .font(.headline)

                Spacer()

                if Payment.Purpose.userSelectableCases.contains(where: { payment.purpose.title == $0.title }) {
                    Menu {
                        Button("Удалить", role: .destructive) {
                            onDelete()
                        }
                    } label: {
                        Label("Удалить", systemImage: "trash")
                            .labelStyle(.iconOnly)
                    }
                }
            }
            .padding(.bottom)

            HStack {
                Text(payment.purpose.descripiton)
                    .lineLimit(3)

                Spacer()

                Text("\(Int(payment.totalAmount)) ₽")
                    .font(.title2)
                    .fontWeight(.medium)
            }

            HStack(alignment: .bottom) {
                Group {
                    Text("Время:")
                    DateText(payment.date, format: .time)
                }
                .font(.footnote)
                .foregroundColor(.secondary)

                Spacer()

                VStack(alignment: .trailing) {
                    if !Payment.Purpose.userSelectableCases.contains(where: { payment.purpose.title == $0.title }),
                       payment.methods.count == 1,
                       let method = payment.methods.first {
                        Menu {
                            ForEach(PaymentType.allCases, id: \.self) { type in
                                Button(type.rawValue) {
                                    payment.updateMethodType(on: type)
                                }
                            }
                        } label: {
                            Text(method.type.rawValue)
                                .font(.subheadline)
                        }
                    } else {
                        ForEach(payment.methods, id: \.self) { method in
                            let text = Text(payment.methods.count > 1 ? " (\(Int(method.value)))" : "")
                            Text("\(method.type.rawValue)\(text)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    PaymentDetailView(payment: .constant(ExampleData.payment1), onDelete: { })
}
