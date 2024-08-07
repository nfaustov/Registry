//
//  PatientsScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 19.02.2024.
//

import SwiftUI
import SwiftData

struct PatientsScreen: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject private var coordinator: Coordinator

    // MARK: - State

    @State private var selection: UUID?
    @State private var searchText: String = ""
    @State private var patients: [Patient] = []

    // MARK: -

    var body: some View {
        Table(patients, selection: $selection) {
            TableColumn("Фамилия", value: \.secondName)
            TableColumn("Имя", value: \.firstName)
            TableColumn("Отчество", value: \.patronymicName)
            TableColumn("Номер телефона", value: \.phoneNumber)
        }
        .searchable(text: $searchText)
        .onChange(of: searchText) { _, newValue in
            withAnimation {
                if newValue.isEmpty {
                    patients = getLastPatients()
                } else {
                    patients = getSearchedPatients()
                }
            }
        }
        .onChange(of: selection) { _, newValue in
            if let selection = newValue,
               let patient = patients.first(where: { $0.id == selection }) {
                coordinator.push(.patientCard(patient))
            }
        }
        .task {
            selection = nil

            if searchText.isEmpty {
                patients = getLastPatients()
            }
        }
    }
}

#Preview {
    NavigationStack {
        PatientsScreen()
            .environmentObject(Coordinator())
            .navigationTitle("Пациенты")
    }
    .previewInterfaceOrientation(.landscapeRight)
}

// MARK: - Calculations

private extension PatientsScreen {
    func getLastPatients() -> [Patient] {
        let database = DatabaseController(modelContext: modelContext)
        return database.getModels(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)],
            limit: 100,
            properties: [\.secondName, \.firstName, \.patronymicName, \.phoneNumber]
        )
    }

    func getSearchedPatients() -> [Patient] {
        let predicate = #Predicate<Patient> { patient in
            searchText.isEmpty ? false :
            patient.secondName.localizedStandardContains(searchText) ||
            patient.firstName.localizedStandardContains(searchText) ||
            patient.patronymicName.localizedStandardContains(searchText)
        }
        let database = DatabaseController(modelContext: modelContext)

        return database.getModels(
            predicate: predicate,
            properties: [\.secondName, \.firstName, \.patronymicName, \.phoneNumber]
        )
    }
}
