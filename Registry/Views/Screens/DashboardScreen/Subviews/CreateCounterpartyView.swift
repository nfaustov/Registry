//
//  CreateCounterpartyView.swift
//  Registry
//
//  Created by Николай Фаустов on 25.06.2024.
//

import SwiftUI

struct CreateCounterpartyView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    let onCreate: (Counterparty) -> Void

    // MARK: - State

    @State private var title: String = ""
    @State private var status: Counterparty.Status = .entity

    // MARK: -

    var body: some View {
        NavigationStack {
            Form {
                Section("Организационно-правовая форма") {
                    Picker(status.rawValue, selection: $status) {
                        ForEach(Counterparty.Status.allCases, id: \.self) { status in
                            Text(status.rawValue)
                        }
                    }
                }

                TextField("Название", text: $title)
            }
            .sheetToolbar("Новый контрагент", disabled: title.isEmpty) {
                let counterparty = Counterparty(title: title, status: status)
                modelContext.insert(counterparty)
                onCreate(counterparty)
            }
        }
    }
}

#Preview {
    CreateCounterpartyView { _ in }
}
