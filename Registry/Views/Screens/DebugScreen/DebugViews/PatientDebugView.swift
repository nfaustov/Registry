//
//  PatientDebugView.swift
//  Registry
//
//  Created by Николай Фаустов on 15.05.2024.
//

import SwiftUI
import SwiftData

struct PatientDebugView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject private var coordinator: Coordinator

    // MARK: - State

    @State private var selection: UUID?
    @State private var patients: [Patient] = []

    // MARK: -

    var body: some View {
        Table(patients, selection: $selection) {
            TableColumn("Фамилия", value: \.secondName)
            TableColumn("Имя", value: \.firstName)
            TableColumn("Отчество", value: \.patronymicName)
            TableColumn("Номер телефона", value: \.phoneNumber)
        }
        .onChange(of: selection) { _, newValue in
            if let selection = newValue,
               let patient = patients.first(where: { $0.id == selection }) {
                coordinator.push(.patientCard(patient))
            }
        }
        .task {
            patients = getPatients()
        }
    }
}

#Preview {
    PatientDebugView()
}

// MARK: - Calculations

private extension PatientDebugView {
    func getPatients() -> [Patient] {
        let database = DatabaseController(modelContext: modelContext)
        return database.getModels(
            sortBy: [
                SortDescriptor(\.secondName, order: .forward),
                SortDescriptor(\.firstName, order: .forward)
            ],
            properties: [\.secondName, \.firstName, \.patronymicName, \.phoneNumber]
        )
    }
}
