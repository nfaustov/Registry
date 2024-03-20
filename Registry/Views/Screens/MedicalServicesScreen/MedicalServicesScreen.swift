//
//  MedicalServicesScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 23.01.2024.
//

import SwiftUI

struct MedicalServicesScreen: View {
    // MARK: - Dependencies

    @Environment(\.user) private var user

    @EnvironmentObject private var coordinator: Coordinator

    // MARK: - State

    @State private var searchText: String = ""
    @State private var selectedPricelistItem: PricelistItem?

    // MARK: -

    var body: some View {
        PricelistView(filterText: searchText, selectedPricelistItem: $selectedPricelistItem)
            .searchable(text: $searchText)
            .catalogToolbar { coordinator.present(.createPricelistItem) }
            .sheet(item: $selectedPricelistItem) { item in
                NavigationStack {
                    Form {
                        Section {
                            Text(item.title)
                            LabeledContent("Цена", value: "\(Int(item.price)) ₽")
                            if user.accessLevel == .boss {
                                LabeledContent("Себестоимость", value: "\(Int(item.costPrice)) ₽")
                            }
                        }

                        if user.accessLevel == .boss {
                            Section {
                                Toggle(isOn: Binding(get: { !item.archived }, set: { value in item.archived = !value })) {
                                    Label(
                                        item.archived ? "Снято с продажи" : "В продаже",
                                        systemImage: item.archived ? "pause.rectangle" : "checkmark.rectangle"
                                    )
                                }
                            }
                        }

                        Section {
                            toggleTreatmentPlan(.pregnancy, forItem: item)
                            toggleTreatmentPlan(.basic, forItem: item)
                        } header: {
                            Text("Лечебные планы")
                        }
                        if !item.treatmentPlans.isEmpty {
                            LabeledContent("Цена по лечебному плану", value: "\(Int(item.treatmentPlanPrice)) ₽")
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
    func toggleTreatmentPlan(_ plan: TreatmentPlan.Kind, forItem item: PricelistItem) -> some View {
        Toggle(
            plan.rawValue,
            isOn: Binding(
                get: { item.treatmentPlans.contains(plan) },
                set: { value in
                    if value {
                        item.treatmentPlans.append(plan)
                    } else {
                        item.treatmentPlans.removeAll(where: { $0 == plan })
                    }
                }
            )
        )
        .disabled(user.accessLevel != .boss)
    }
}
