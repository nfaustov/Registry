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

    @Binding var bill: Bill
    @Binding var isPricelistPresented: Bool

    @Query private var billTemplates: [BillTemplate]

    // MARK: -

    var body: some View {
        HStack {
            Menu {
                Section {
                    Button(role: .destructive) {
                        withAnimation {
                            bill.services = []
                            bill.discount = 0
                        }
                    } label: {
                        Label("Очистить", systemImage: "trash")
                    }
                    .disabled(bill.services.isEmpty)
                }

                Button {
                    coordinator.present(.createBillTemplate(services: bill.services))
                } label: {
                    Label("Создать шаблон", systemImage: "note.text.badge.plus")
                }
                .disabled(bill.services.isEmpty)

                Menu {
                    ForEach(billTemplates) { template in
                        Button(template.title) {
                            withAnimation {
                                bill.services.append(contentsOf: template.services)
                                bill.discount += template.discount
                            }
                        }
                    }
                } label: {
                    Label("Использовать шаблон", systemImage: "note.text")
                }
                .disabled(billTemplates.isEmpty)
            } label: {
                Label("Действия", systemImage: "ellipsis.circle")
            }
            .disabled(isPricelistPresented || (bill.services.isEmpty && billTemplates.isEmpty))

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
        bill: .constant(Bill(services: [ExampleData.service])),
        isPricelistPresented: .constant(false)
    )
}
