//
//  CreatePricelistItemView.swift
//  Registry
//
//  Created by Николай Фаустов on 23.01.2024.
//

import SwiftUI

struct CreatePricelistItemView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    // MARK: - State

    @State private var idText: String = ""
    @State private var serviceTitleText: String = ""
    @State private var priceValue: Double = 0
    @State private var costPriceValue: Double = 0
    @State private var category: Department? = nil

    //MARK: -

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Menu(category?.rawValue ?? "Категория") {
                        ForEach(Department.allCases) { department in
                            Button(department.rawValue) {
                                category = department
                            }
                        }
                    }
                } header: {
                    Text("Категория")
                }

                Section {
                    TextField("Код", text: $idText)
                    TextField("Наименование", text: $serviceTitleText)
                    TextField("Цена", value: $priceValue, format: .number, prompt: Text("Цена"))
                    TextField("Себестоимость", value: $costPriceValue, format: .number, prompt: Text("Себестоимость"))
                } header: {
                    Text("Услуга")
                }
            }
            .sheetToolbar(title: "Новая услуга", confirmationDisabled: category == nil || emptyTextDetection) {
                guard let category else { return }

                let priceListItem = PricelistItem(
                    id: idText,
                    category: category,
                    title: serviceTitleText,
                    price: priceValue,
                    costPrice: costPriceValue
                )

                modelContext.insert(priceListItem)
            }
        }
    }
}

#Preview {
    CreatePricelistItemView()
}

// MARK: - Calculations

private extension CreatePricelistItemView {
    var emptyTextDetection: Bool {
        idText.isEmpty || serviceTitleText.isEmpty || priceValue == 0
    }
}
