//
//  CounterpartiesList.swift
//  Registry
//
//  Created by Николай Фаустов on 25.06.2024.
//

import SwiftUI
import SwiftData

struct CounterpartiesList: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Binding var selectedCounterparty: Counterparty?

    // MARK: - State

    @State private var searchText: String = ""
    @State private var addCounterparty: Bool = false

    // MARK: -

    var body: some View {
        NavigationStack {
            List {
                Button {
                    addCounterparty = true
                } label: {
                    Label("Добавить контрагента", systemImage: "plus")
                        .foregroundStyle(.blue)
                }

                ForEach(searchedCounterparties) { counterparty in
                    Button {
                        selectedCounterparty = counterparty
                        dismiss()
                    } label: {
                        Text(counterparty.fullTitle)
                    }
                }
                .onDelete(perform: removeCounterparty)
            }
            .listStyle(.inset)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always)
            )
            .sheetToolbar("Выберите контрагента")
            .sheet(isPresented: $addCounterparty) {
                CreateCounterpartyView { counterparty in
                    selectedCounterparty = counterparty
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    CounterpartiesList(selectedCounterparty: .constant(nil))
}

// MARK: - Calculations

private extension CounterpartiesList {
    var searchedCounterparties: [Counterparty] {
        let predicate = #Predicate<Counterparty> { counterparty in
            searchText.isEmpty ? true : counterparty.title.localizedStandardContains(searchText)
        }
        let descriptor = FetchDescriptor(predicate: predicate)

        if let counterparties = try? modelContext.fetch(descriptor) {
            return counterparties
        } else { return [] }
    }

    func removeCounterparty(at offsets: IndexSet) {
        offsets.forEach { index in
            modelContext.delete(searchedCounterparties[index])
        }
    }
}
