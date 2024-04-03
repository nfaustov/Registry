//
//  ServicesTable.swift
//  Registry
//
//  Created by Николай Фаустов on 27.02.2024.
//

import SwiftUI

struct ServicesTable: View {
    // MARK: - Dependencies

    @Binding var bill: Bill

    let doctor: Doctor
    let editMode: Bool

    // MARK: - State

    @State private var sortOrder = [KeyPathComparator(\RenderedService.performer?.secondName)]
    @State private var selection: Set<RenderedService.ID> = []

    @State private var isTargeted: Bool = false

    // MARK: -

    var body: some View {
        Table(bill.services, selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Услуга", value: \.pricelistItem.title) { service in
                Text(service.pricelistItem.title)
                    .lineLimit(4)
            }.width(600)
            TableColumn("Стоимость", value: \.pricelistItem.price) { service in
                Text("\(Int(service.pricelistItem.price)) ₽")
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }.width(120)
            TableColumn("Исполнитель") { service in
                Text(service.performer?.initials ?? "-")
                    .foregroundColor(.secondary)
            }
            TableColumn("Агент") { service in
                Text(service.agent?.initials ?? "-")
                    .foregroundColor(.secondary)
            }
        }
        .overlay { if editMode { tableOverlay } }
        .contextMenu(forSelectionType: RenderedService.ID.self) { servicesID in
            if let id = servicesID.first {
                ServiceMenuView(bill: $bill, serviceID: id)
            }
        }
        .onChange(of: sortOrder) { _, newValue in
            bill.services.sort(using: newValue)
        }
    }
}

#Preview {
    ServicesTable(bill: .constant(Bill(services: [])), doctor: ExampleData.doctor, editMode: false)
}

// MARK: - Subviews

private extension ServicesTable {
    var tableOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .foregroundColor(isTargeted ? Color.green.opacity(0.15) : Color.black.opacity(0.1))
        }
        .dropDestination(for: PricelistItem.self) { droppedItems, location in
            for item in droppedItems {
                let renderedService = RenderedService(
                    pricelistItem: item.short,
                    performer: item.category == .laboratory ? nil : doctor.employee,
                    agent: item.category == .laboratory ? (doctor.department == .procedure ? nil : doctor.employee) : nil
                )
                withAnimation {
                    bill.services.insert(renderedService, at: 0)
                }
            }

            return true
        } isTargeted: { isTargeted in
            self.isTargeted = isTargeted
        }
    }
}
