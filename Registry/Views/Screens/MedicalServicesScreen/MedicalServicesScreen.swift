//
//  MedicalServicesScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 23.01.2024.
//

import SwiftUI

struct MedicalServicesScreen: View {
    // MARK: - Dependencies

    @EnvironmentObject private var coordinator: Coordinator

    // MARK: - State

    @State private var searchText: String = ""
    @State private var selectedPricelistItem: PricelistItem?

    // MARK: -

    var body: some View {
        PricelistView(filterText: searchText, selectedPricelistItem: $selectedPricelistItem)
            .searchable(text: $searchText)
            .overlay {
                if searchText.isEmpty {
                    ContentUnavailableView("Услуги не найдены", systemImage: "magnifyingglass", description: Text("Введите название или код услуги в поле для поиска"))
                }
            }
            .catalogToolbar { coordinator.present(.createPricelistItem) }
            .sheet(item: $selectedPricelistItem) { item in
                NavigationStack {
                    Form {
                        Text(item.title)
                        LabeledContent("Цена", value: "\(Int(item.price)) ₽")
                        if item.costPrice > 0 {
                            LabeledContent("Себестоимость", value: "\(Int(item.costPrice)) ₽")
                        }

                        Section {
                            archivingToggle(item: item)
                        }
                    }
                    .sheetToolbar(title: "Услуга")
                }
            }
    }
}

#Preview {
    NavigationStack {
        MedicalServicesScreen()
            .environmentObject(Coordinator())
            .navigationTitle("Услуги")
    }
    .previewInterfaceOrientation(.landscapeRight)
}

// MARK: - Subviews

private extension MedicalServicesScreen {
    func archivingToggle(item: PricelistItem) -> some View {
        Toggle(isOn: Binding(get: { !item.archived }, set: { value in item.archived = !value })) {
            Label(
                item.archived ? "Снято с продажи" : "В продаже",
                systemImage: item.archived ? "pause.rectangle" : "checkmark.rectangle"
            )
        }
    }
}
