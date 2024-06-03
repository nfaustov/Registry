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
    @Environment(\.modelContext) private var modelContext

    @Query private var doctors: [Doctor]

    let doctor: Doctor

    @Bindable var check: Check
    @Binding var editMode: Bool

    // MARK: - State

    @State private var sortOrder = [KeyPathComparator(\MedicalService.performer?.secondName)]
    @State private var selection: Set<PersistentIdentifier> = []
    @State private var isTargeted: Bool = false
    @State private var predictions: [PricelistItem] = []
    @State private var predictionsEnabled: Bool = true
    @State private var correlations: [PricelistItemsCorrelation] = []
    @State private var errorMessage: String?

    // MARK: -

    var body: some View {
        VStack(spacing: 0) {
            Table(check.services, selection: $selection, sortOrder: $sortOrder) {
                TableColumn("Услуга") { service in
                    Text(service.pricelistItem.title)
                        .lineLimit(4)
                }.width(600)
                TableColumn("Стоимость") { service in
                    CurrencyText(service.treatmentPlanPrice ?? service.pricelistItem.price)
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

                        if patient.currentTreatmentPlan == nil {
                            menu(of: \.agent, for: id)
                        }
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
                withAnimation {
                    makePredictions(basedOn: newValue)
                }
            }
            .task {
                let checksController = ChecksController(modelContainer: modelContext.container)
                correlations = await checksController.pricelistItemsCorrelations

                withAnimation {
                    makePredictions(basedOn: check.services)
                }
            }

            if purpose == .createAndPay {
                if predictionsEnabled, !predictions.isEmpty {
                    PredictionsView(
                        predictions: predictions,
                        treatmentPlan: patient.currentTreatmentPlan?.kind
                    ) {
                        addToCheck(pricelistItem: $0)
                    }
                    .padding(.vertical, 8)
                }

                ServicesTableControls(check: check, isPricelistPresented: $editMode, predictions: $predictionsEnabled.animation())
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
                withAnimation {
                    addToCheck(pricelistItem: item)
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
    var patient: Patient {
        guard let patient = check.appointments?.first?.patient else { fatalError() }
        return patient
    }

    func service(with id: PersistentIdentifier) -> MedicalService? {
        check.services.first(where: { $0.id == id })
    }

    func addToCheck(pricelistItem: PricelistItem) {
        var agent: Doctor? = nil

        if pricelistItem.category == .laboratory, 
            doctor.department != .procedure,
            patient.currentTreatmentPlan == nil {
            agent = doctor
        }

        var treatmentPlanPrice: Double? = nil

        if let treatmentPlan = patient.currentTreatmentPlan {
            treatmentPlanPrice = pricelistItem.treatmentPlanPrice(treatmentPlan.kind)
        }

        let medicalService = MedicalService(
            pricelistItem: pricelistItem.snapshot,
            treatmentPlanPrice: treatmentPlanPrice,
            performer: pricelistItem.category == .laboratory ? nil : doctor,
            agent: agent
        )
        check.services.insert(medicalService, at: 0)
    }

    func getPredictedPricelistItems(with identifiers: [String]) throws -> [PricelistItem] {
        let predicate = #Predicate<PricelistItem> { identifiers.contains($0.id) }
        let descriptor = FetchDescriptor(predicate: predicate)

        if let items = try? modelContext.fetch(descriptor) {
            return items
        } else { return [] }
    }

    func makePredictions(basedOn services: [MedicalService]) {
        let itemsIDs = services.map { $0.pricelistItem.id }
        var predictionsIDs = correlations
            .filter { itemsIDs.contains($0.itemID) }
            .sorted(by: { $0.usage > $1.usage })
            .map { $0.correlatedItemID }

        if predictionsIDs.count > 5 {
            predictionsIDs = predictionsIDs.dropLast(predictionsIDs.count - 5)
        }

        do {
            predictions = try getPredictedPricelistItems(with: predictionsIDs)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
