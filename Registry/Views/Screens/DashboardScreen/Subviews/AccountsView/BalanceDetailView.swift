//
//  BalanceDetailView.swift
//  Registry
//
//  Created by Николай Фаустов on 25.06.2024.
//

import SwiftUI

struct BalanceDetailView: View {
    // MARK: - Dependencies

    private let anyPersons: [AnyPerson]

    // MARK: -

    init(persons: [AccountablePerson]) {
        anyPersons = persons.map { AnyPerson(name: $0.fullName, balance: $0.balance) }
    }

    var body: some View {
        NavigationStack {
            List(anyPersons, id: \.self) { person in
                LabeledCurrency(person.name, value: person.balance)
            }
            .sheetToolbar("Балансы")
        }
    }
}

#Preview {
    BalanceDetailView(persons: [ExampleData.doctor])
}

struct AnyPerson: Hashable, Identifiable {
    let id: UUID = UUID()
    let name: String
    let balance: Double
}
