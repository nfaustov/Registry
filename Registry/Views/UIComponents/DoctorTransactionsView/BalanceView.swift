//
//  BalanceView.swift
//  Registry
//
//  Created by Николай Фаустов on 04.06.2024.
//

import SwiftUI

struct BalanceView: View {
    // MARK: - Dependencies

    @EnvironmentObject private var coordinator: Coordinator

    let person: AccountablePerson

    // MARK: -

    var body: some View {
        HStack {
            Text("Баланс: \(Int(person.balance)) ₽")
                .foregroundStyle(person.balance < 0 ? .red : .primary)
                .font(.headline)

            Spacer()

            Button {
                coordinator.present(.updateBalance(for: person, kind: .refill))
            } label: {
                Text("Пополнить")
                    .frame(width: 120)
            }
            .buttonStyle(.borderedProminent)

            Button {
                coordinator.present(.updateBalance(for: person, kind: .payout))
            } label: {
                Text("Списать")
                    .frame(width: 120)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    BalanceView(person: ExampleData.patient)
        .environmentObject(Coordinator())
}
