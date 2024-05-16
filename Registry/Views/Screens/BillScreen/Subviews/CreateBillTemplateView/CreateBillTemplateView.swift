//
//  CreateBillTemplateView.swift
//  Registry
//
//  Created by Николай Фаустов on 27.02.2024.
//

import SwiftUI

struct CreateBillTemplateView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    let services: [MedicalService]

    // MARK: - State

    @State private var templateTitleText: String = ""
    @State private var discount: Double = .zero
    @State private var discountRate: Double = .zero
    @State private var discountType: DiscountType = .rate

    // MARK: -

    var body: some View {
        NavigationStack {
            Form {
                TextField("Название", text: $templateTitleText)

                Section {
                    ForEach(services) { service in
                        HStack(spacing: 8) {
                            Text(service.pricelistItem.title)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(service.performer?.initials ?? "-")
                                .frame(width: 128, alignment: .leading)
                            Text(service.agent?.initials ?? "-")
                                .frame(width: 128, alignment: .leading)
                        }
                        .font(.footnote)
                    }
                } header: {
                    HStack(spacing: 8) {
                        Text("Услуга")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Исполнитель")
                            .frame(width: 128, alignment: .leading)
                        Text("Агент")
                            .frame(width: 128, alignment: .leading)
                    }
                }

                Section {
                    let price = services
                        .map{ $0.pricelistItem.price }
                        .reduce(0, +)

                    LabeledCurrency("Цена", value: price)
                    Picker("Скидка", selection: $discountType) {
                        ForEach(DiscountType.allCases, id: \.self) { type in
                            Text(type.rawValue)
                                .tag(type.rawValue)
                        }
                    }

                    if discountType == .rate {
                        LabeledContent("\(Int(discountRate * 100))%") {
                            Slider(value: $discountRate, in: 0...0.5, step: 0.01)
                                .onChange(of: discountRate) { _, newValue in
                                    discount = price * newValue
                                }
                        }
                        LabeledCurrency("Итог", value: price - price * discountRate)
                    } else if discountType == .amount {
                        MoneyFieldSection(value: $discount) {
                            LabeledCurrency("Итог", value: price - discount)
                        }
                    }
                }
            }
            .sheetToolbar("Новый шаблон", disabled: templateTitleText.isEmpty) {
                let template = CheckTemplate(title: templateTitleText, services: services, discount: discount)
                modelContext.insert(template)
            }
        }
    }
}

#Preview {
    CreateBillTemplateView(services: [])
}

// Calculations

private extension CreateBillTemplateView {
    enum DiscountType: String, Hashable, CaseIterable {
        case rate = "Процент"
        case amount = "Сумма"
    }
}
