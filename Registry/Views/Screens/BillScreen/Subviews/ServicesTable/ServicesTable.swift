//
//  ServicesTable.swift
//  Registry
//
//  Created by Николай Фаустов on 27.02.2024.
//

import SwiftUI
import SwiftData

struct ServicesTable: View {
    // MARK: - Dependencies

    @Environment(\.servicesTablePurpose) private var purpose

    @Query private var doctors: [Doctor]

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
        .contextMenu(forSelectionType: RenderedService.ID.self) { selectionIdentifiers in
            if let id = selectionIdentifiers.first {
                Section {
                    if let service = service(with: id), service.pricelistItem.category != .laboratory {
                        menu(of: \.performer, for: id)
                    }

                    menu(of: \.agent, for: id)
                }

                if purpose == .createAndPay {
                    Section {
                        Button(role: .destructive) {
                            withAnimation {
                                bill.services.removeAll(where: { $0.id == id })
                            }
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
                }
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
        } isTargeted: { isTargeted = $0 }
    }

    func menu(of kind: WritableKeyPath<RenderedService, AnyEmployee?>, for serviceID: RenderedService.ID) -> some View {
        Menu(kind == \.performer ? "Исполнитель" : "Агент") {
            doctorButton(nil, role: kind, for: serviceID)
            ForEach(doctors) { doctor in
                doctorButton(doctor, role: kind, for: serviceID)
            }
        }
    }

    func doctorButton(_ doctor: Doctor?, role: WritableKeyPath<RenderedService, AnyEmployee?>, for serviceID: RenderedService.ID) -> some View {
        Button(doctor?.initials ?? "-") {
            withAnimation {
                if let service = service(with: serviceID) {
                    var updatedService = service
                    updatedService[keyPath: role] = doctor?.employee
                    bill.services.replace([service], with: [updatedService])
                }
            }
        }
    }
}

// MARK: - Calculations

private extension ServicesTable {
    func service(with id: UUID) -> RenderedService? {
        bill.services.first(where: { $0.id == id })
    }
}

// MARK: - Purpose

enum ServicesTablePurpose {
    case createAndPay
    case editRoles
}

private struct ServicesTablePurposeKey: EnvironmentKey {
    static var defaultValue: ServicesTablePurpose = .createAndPay
}

extension EnvironmentValues {
    var servicesTablePurpose: ServicesTablePurpose {
        get { self[ServicesTablePurposeKey.self] }
        set { self[ServicesTablePurposeKey.self] = newValue }
    }
}

extension View {
    func servicesTablePurpose(_ purpose: ServicesTablePurpose) -> some View {
        environment(\.servicesTablePurpose, purpose)
    }
}
