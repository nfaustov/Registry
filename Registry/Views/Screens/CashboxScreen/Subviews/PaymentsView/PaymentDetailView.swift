//
//  PaymentDetailView.swift
//  Registry
//
//  Created by Николай Фаустов on 21.02.2024.
//

import SwiftUI

struct PaymentDetailView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    var payment: Payment

    var onDelete: () -> Void

    // MARK: -

    var body: some View {
        VStack(alignment: .leading) {
            Divider()
                .padding(.bottom)

            HStack {
                Text(payment.purp.rawValue)
                    .font(.headline)

                Spacer()

                if PaymentPurpose.userSelectableCases.contains(payment.purp) {
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
                Text(payment.details)
                    .lineLimit(3)

                Spacer()

                CurrencyText(payment.totalAmount)
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
                    if !PaymentPurpose.userSelectableCases.contains(payment.purp) {
                        ForEach(payment.methods, id: \.self) { method in
                            Menu {
                                ForEach(PaymentType.allCases, id: \.self) { type in
                                    if !payment.methods.contains(where: { $0.type == type }) {
                                        Button(type.rawValue) {
                                            payment.updateMethod(withType: method.type, on: type)
                                        }
                                    }
                                }
                            } label: {
                                let text = Text(payment.methods.count > 1 ? " (\(Int(method.value)))" : "")
                                Text("\(method.type.rawValue)\(text)")
                                    .font(.subheadline)
                            }
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
    PaymentDetailView(payment: ExampleData.payment1, onDelete: { })
}
