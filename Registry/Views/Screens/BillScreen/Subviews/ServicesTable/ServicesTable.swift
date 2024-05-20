//
//  ServicesTable.swift
//  Registry
//
//  Created by Николай Фаустов on 27.02.2024.
//

import SwiftUI
import SwiftData
import CoreML

struct ServicesTable: View {
    // MARK: - Dependencies

    @Environment(\.servicesTablePurpose) private var purpose
    @Environment(\.modelContext) private var modelContext

    @Query private var doctors: [Doctor]

    let doctor: Doctor

    @Bindable var check: Check
    @Binding var editMode: Bool

    // MARK: - State

    @State private var sortOrder = [KeyPathComparator(\MedicalService.performer?.secondName)]
    @State private var selection: Set<PersistentIdentifier> = []
    @State private var isTargeted: Bool = false
    @State private var predictions: [PricelistItem.Snapshot] = []
    @State private var predictionsEnabled: Bool = true
    @State private var errorMessage: String?

    // MARK: -

    var body: some View {
        VStack(spacing: 0) {
            Table(check.services, selection: $selection, sortOrder: $sortOrder) {
                TableColumn("Услуга", value: \.pricelistItem.title) { service in
                    Text(service.pricelistItem.title)
                        .lineLimit(4)
                }.width(600)
                TableColumn("Стоимость", value: \.pricelistItem.price) { service in
                    CurrencyText(service.pricelistItem.price)
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
            .onChange(of: check.services) { _, newValue in
                let snapshots = check.services.map { $0.pricelistItem }
                makePredictions(items: snapshots)
            }
            .onAppear {
                if !check.services.isEmpty {
                    let snapshots = check.services.map { $0.pricelistItem }
                    makePredictions(items: snapshots)
                }
            }

            if purpose == .createAndPay {
                if predictionsEnabled, !predictions.isEmpty {
                    predictionsView
                }

                ServicesTableControls(check: check, isPricelistPresented: $editMode, predictions: $predictionsEnabled)
                    .padding()
                    .background(.regularMaterial)
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
                addToCheck(pricelistItem: item.snapshot)
            }

            return true
        } isTargeted: { isTargeted = $0 }
    }

    var predictionsView: some View {
        VStack {
            ForEach(predictions) { item in
                Button {
                    addToCheck(pricelistItem: item)
                } label: {
                    LabeledCurrency(item.title, value: item.price)
                        .font(.footnote)
                        .foregroundStyle(.purple)
                        .padding(12)
                        .background(.purple.opacity(0.2))
                        .clipShape(.rect(cornerRadius: 12, style: .continuous))
                        .padding(.horizontal)
                }
            }
        }
        .padding(.top)
        .background(.regularMaterial)
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

    func getPredictions(with identifiers: [String]) throws -> [PricelistItem.Snapshot] {
        let predicate = #Predicate<PricelistItem> { identifiers.contains($0.id) }
        let descriptor = FetchDescriptor(predicate: predicate)

        if let items = try? modelContext.fetch(descriptor) {
            return items.map { $0.snapshot }
        } else { return [] }
    }

    func addToCheck(pricelistItem: PricelistItem.Snapshot) {
        let medicalService = MedicalService(
            pricelistItem: pricelistItem,
            performer: pricelistItem.category == .laboratory ? nil : doctor,
            agent: pricelistItem.category == .laboratory ? (doctor.department == .procedure ? nil : doctor) : nil
        )
        withAnimation {
            check.services.insert(medicalService, at: 0)
        }
    }

    func makePredictions(items: [PricelistItem.Snapshot]) {
        do {
            let config = MLModelConfiguration()
            let model = try PricelistItemRecommender(configuration: config)
            var dict: [String: Double] = [:]
            items.forEach { dict[$0.id] = 0 }
            let prediction = try model.prediction(items: dict, k: 5, restrict_: nil, exclude: nil)
            predictions = try getPredictions(with: prediction.recommendations)
        } catch {
            errorMessage = error.localizedDescription
        }
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
