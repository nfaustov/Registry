//
//  PaymentDetailView.swift
//  Registry
//
//  Created by Николай Фаустов on 21.02.2024.
//

import SwiftUI

struct PaymentDetailView: View {
    // MARK: - Dependencies

    let payment: Payment
    var onDelete: () -> Void

    // MARK: -

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

            HStack(spacing: 40) {
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

#Preview {
    PaymentDetailView(payment: ExampleData.payment1, onDelete: { })
}
