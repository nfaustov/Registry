//
//  ServicesTableControls.swift
//  Registry
//
//  Created by Николай Фаустов on 12.04.2024.
//

import SwiftUI
import SwiftData

struct ServicesTableControls: View {
    // MARK: - Dependencies

    @EnvironmentObject private var coordinator: Coordinator

    @Bindable var check: Check
    @Binding var isPricelistPresented: Bool

    @Query private var checkTemplates: [CheckTemplate]

    // MARK: -

    var body: some View {
        HStack {
            Menu {
                Section {
                    Button(role: .destructive) {
                        withAnimation {
                            check.services = []
                            check.discount = 0
                        }
                    } label: {
                        Label("Очистить", systemImage: "trash")
                    }
                    .disabled(check.services.isEmpty)
                }

                Button {
                    coordinator.present(.createBillTemplate(services: check.services))
                } label: {
                    Label("Создать шаблон", systemImage: "note.text.badge.plus")
                }
                .disabled(check.services.isEmpty)

                Menu {
                    ForEach(checkTemplates) { template in
                        Button(template.title) {
                            let templateServices = template.getCopy()

                            withAnimation {
                                check.services.append(contentsOf: templateServices)
                                check.discount += template.discount
                            }
                        }
                    }
                } label: {
                    Label("Использовать шаблон", systemImage: "note.text")
                }
                .disabled(checkTemplates.isEmpty)
            } label: {
                Label("Действия", systemImage: "ellipsis.circle")
            }
            .disabled(isPricelistPresented || (check.services.isEmpty && checkTemplates.isEmpty))

            Spacer()

            Button {
                withAnimation {
                    isPricelistPresented = true
                }
            } label: {
                HStack {
                    Text("Добавить услуги")
                    Image(systemName: "chevron.right")
                }
            }
        }
    }
}

#Preview {
    ServicesTableControls(
        check: Check(services: []),
        isPricelistPresented: .constant(false)
    )
}
