//
//  PricelistItemView.swift
//  Registry
//
//  Created by Николай Фаустов on 21.03.2024.
//

import SwiftUI

struct PricelistItemView: View {
    // MARK: - Dependencies

    @Environment(\.user) private var user
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let pricelistItem: PricelistItem

    // MARK: - State

    @State private var title: String
    @State private var price: Double
    @State private var costPrice: Double
    @State private var fixedSalary: Double?
    @State private var fixedAgentFee: Double?
    @State private var fixedDoctorsSalary: Bool
    @State private var fixedDoctorAgentFee: Bool

    // MARK: -

    init(pricelistItem: PricelistItem) {
        self.pricelistItem = pricelistItem
        _title = State(initialValue: pricelistItem.title)
        _price = State(initialValue: pricelistItem.price)
        _costPrice = State(initialValue: pricelistItem.costPrice)
        _fixedSalary = State(initialValue: pricelistItem.fixedSalary)
        _fixedAgentFee = State(initialValue: pricelistItem.fixedAgentFee)
        _fixedDoctorsSalary = State(initialValue: pricelistItem.fixedSalary != nil)
        _fixedDoctorAgentFee = State(initialValue: pricelistItem.fixedAgentFee != nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if user.accessLevel == .boss {
                        TextField("Наименование", text: $title)
                        LabeledContent {
                            TextField("Цена:", value: $price, format: .number)
                        } label: {
                            Text("Цена:")
                        }
                        LabeledContent {
                            TextField("Себестоимость:", value: $costPrice, format: .number)
                        } label: {
                            Text("Себестоимость:")
                        }
                    } else {
                        Text(pricelistItem.title)
                        LabeledContent("Цена", value: "\(Int(pricelistItem.price)) ₽")
                    }
                }

                if user.accessLevel == .boss || fixedDoctorsSalary {
                    Section {
                        if user.accessLevel == .boss {
                            if fixedDoctorsSalary {
                                HStack {
                                    TextField("Премия врача", value: $fixedSalary, format: .number)
                                    Button("Отменить", role: .destructive) {
                                        fixedSalary = nil
                                        fixedDoctorsSalary = false
                                    }
                                }
                            } else {
                                Button("Зафиксировать оплату врача") { fixedDoctorsSalary = true }
                            }

                            if fixedDoctorAgentFee {
                                HStack {
                                    TextField("Агентские", value: $fixedAgentFee, format: .number)
                                    Button("Отменить", role: .destructive) {
                                        fixedAgentFee = nil
                                        fixedDoctorAgentFee = false
                                    }
                                }
                            } else {
                                Button("Зафиксировать агентские врача") { fixedDoctorAgentFee = true }
                            }
                        } else {
                            if let fixedSalary {
                                Text("\(Int(fixedSalary)) ₽")
                            }
                            if let fixedAgentFee {
                                Text("\(Int(fixedAgentFee)) ₽")
                            }
                        }
                    } header: {
                        Text("Фиксированная премия врача")
                    }
                }


                if user.accessLevel == .boss {
                    Section {
                        Toggle(isOn: Binding(get: { !pricelistItem.archived }, set: { value in pricelistItem.archived = !value })) {
                            Label(
                                pricelistItem.archived ? "Снято с продажи" : "В продаже",
                                systemImage: pricelistItem.archived ? "pause.rectangle" : "checkmark.rectangle"
                            )
                        }
                    }

                    Section {
                        Button("Удалить", role: .destructive) {
                            dismiss()
                            modelContext.delete(pricelistItem)
                        }
                    }
                }

                Section {
                    toggleTreatmentPlan(.pregnancy)
                    toggleTreatmentPlan(.basic)
                } header: {
                    Text("Лечебные планы")
                }

                if !pricelistItem.treatmentPlans.isEmpty {
                    LabeledContent("Цена по лечебному плану", value: "\(Int(pricelistItem.treatmentPlanPrice)) ₽")
                }
            }
            .sheetToolbar(
                "Услуга",
                onConfirm: user.accessLevel != .boss ? nil : { 
                    pricelistItem.title = title
                    pricelistItem.price = price
                    pricelistItem.costPrice = costPrice
                    pricelistItem.fixedSalary = fixedSalary
                    pricelistItem.fixedAgentFee = fixedAgentFee
                }
            )
        }
    }
}

#Preview {
    PricelistItemView(pricelistItem: ExampleData.pricelistItem)
}

// MARK: - Subviews

private extension PricelistItemView {
    func toggleTreatmentPlan(_ plan: TreatmentPlan.Kind) -> some View {
        Toggle(
            plan.rawValue,
            isOn: Binding(
                get: { pricelistItem.treatmentPlans.contains(plan) },
                set: { value in
                    if value {
                        pricelistItem.treatmentPlans.append(plan)
                    } else {
                        pricelistItem.treatmentPlans.removeAll(where: { $0 == plan })
                    }
                }
            )
        )
        .disabled(user.accessLevel != .boss)
    }
}
