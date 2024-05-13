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

    let doctor: Doctor

    @Bindable var check: Check
    @Binding var editMode: Bool

    // MARK: - State

    @State private var sortOrder = [KeyPathComparator(\MedicalService.performer?.secondName)]
    @State private var selection: Set<PersistentIdentifier> = []
    @State private var isTargeted: Bool = false

    // MARK: -

    var body: some View {
        VStack(spacing: 0) {
            Table(check.services, selection: $selection, sortOrder: $sortOrder) {
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
            .contextMenu(forSelectionType: PersistentIdentifier.self) { selectionIdentifiers in
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
                                    check.services.removeAll(where: { $0.id == id })
                                }
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .onChange(of: sortOrder) { _, newValue in
                check.services.sort(using: newValue)
            }

            if purpose == .createAndPay {
                ServicesTableControls(check: check, isPricelistPresented: $editMode)
                    .padding()
            }
        }
    }
}

#Preview {
    ServicesTable(doctor: ExampleData.doctor, check: Check(services: []), editMode: .constant(false))
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
                let medicalService = MedicalService(
                    pricelistItem: item.snapshot,
                    performer: item.category == .laboratory ? nil : doctor,
                    agent: item.category == .laboratory ? (doctor.department == .procedure ? nil : doctor) : nil
                )
                withAnimation {
                    check.services.insert(medicalService, at: 0)
                }
            }

            return true
        } isTargeted: { isTargeted = $0 }
    }

    func menu(of kind: WritableKeyPath<MedicalService, Doctor?>, for serviceID: PersistentIdentifier) -> some View {
        Menu(kind == \.performer ? "Исполнитель" : "Агент") {
            doctorButton(nil, role: kind, for: serviceID)
            ForEach(doctors) { doctor in
                doctorButton(doctor, role: kind, for: serviceID)
            }
        }
    }

    func doctorButton(_ doctor: Doctor?, role: WritableKeyPath<MedicalService, Doctor?>, for serviceID: PersistentIdentifier) -> some View {
        Button(doctor?.initials ?? "-") {
            withAnimation {
                if var service = service(with: serviceID) {
                    if purpose == .editRoles { service.charge(.cancel, for: role) }
                    service[keyPath: role] = doctor
                    if purpose == .editRoles { service.charge(.make, for: role) }
                }
            }
        }
    }
}

// MARK: - Calculations

private extension ServicesTable {
    func service(with id: PersistentIdentifier) -> MedicalService? {
        check.services.first(where: { $0.id == id })
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
