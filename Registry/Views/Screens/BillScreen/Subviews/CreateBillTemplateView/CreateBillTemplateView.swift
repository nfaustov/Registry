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

    let services: [RenderedService]

    // MARK: - State

    @State private var templateTitleText: String = ""
    @State private var discount: Double = .zero

    // MARK: -

    var body: some View {
        NavigationStack {
            List {
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

                VStack {
                    Text("Скидка: \(Int(discount))%")
                    Slider(value: $discount, in: 0...50, step: 1)
                }
            }
            .sheetToolbar(title: "Новый шаблон", confirmationDisabled: templateTitleText.isEmpty) {
                let template = BillTemplate(title: templateTitleText, services: services, discount: discount)
                modelContext.insert(template)
            }
        }
    }
}

#Preview {
    CreateBillTemplateView(services: [])
}
