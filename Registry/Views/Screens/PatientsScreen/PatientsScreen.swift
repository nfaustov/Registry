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

    @Query(initialDescriptor) private var patients: [Patient]

    // MARK: - State

    @State private var selection: Patient.ID?
    @State private var searchText: String = ""

    // MARK: -

    var body: some View {
        if let searchedPatients = try? modelContext.fetch(searchDescriptor) {
            Table(searchText.isEmpty ? patients : searchedPatients, selection: $selection) {
                TableColumn("Фамилия", value: \.secondName)
                TableColumn("Имя", value: \.firstName)
                TableColumn("Отчество", value: \.patronymicName)
                TableColumn("Номер телефона", value: \.phoneNumber)
            }
            .searchable(text: $searchText)
            .onChange(of: selection) { _, newValue in
                if let selection = newValue,
                   let patient = patients.first(where: { $0.id == selection }) {
                    coordinator.push(.patientCard(patient))
                }
            }
            .onAppear {
                selection = nil
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
    static var initialDescriptor: FetchDescriptor<Patient> {
        var descriptor = FetchDescriptor<Patient>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        descriptor.fetchLimit = 100
        descriptor.propertiesToFetch = [\.secondName, \.firstName, \.patronymicName, \.phoneNumber]

        return descriptor
    }

    var searchDescriptor: FetchDescriptor<Patient> {
        let patientsPredicate = #Predicate<Patient> { patient in
            searchText.isEmpty ? false :
            patient.secondName.localizedStandardContains(searchText) ||
            patient.firstName.localizedStandardContains(searchText) ||
            patient.patronymicName.localizedStandardContains(searchText)
        }
        var descriptor = FetchDescriptor(predicate: patientsPredicate)
        descriptor.propertiesToFetch = [\.secondName, \.firstName, \.patronymicName, \.phoneNumber]

        return descriptor
    }
}
