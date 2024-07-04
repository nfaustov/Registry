//
//  PatientsList.swift
//  Registry
//
//  Created by Николай Фаустов on 25.02.2024.
//

import SwiftUI
import SwiftData

struct PatientsList: View {
    // MARK: - Dependencies

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Binding var selectedPatient: Patient?

    // MARK: - State

    @State private var searchText: String = ""

    // MARK: -

    var body: some View {
        NavigationStack {
            List(searchText.isEmpty ? initialPatients : searchedPatients) { patient in
                Button {
                    selectedPatient = patient
                    dismiss()
                } label: {
                    LabeledContent {
                        Text(patient.phoneNumber)
                    } label: {
                        HStack {
                            if patient.currentTreatmentPlan != nil {
                                Image(systemName: "cross.case.circle")
                                    .foregroundStyle(.orange)
                            }

                            Text(patient.fullName)
                        }
                    }
                }
            }
            .listStyle(.inset)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always)
            )
            .sheetToolbar("Выберите пациента")
            .animation(.default, value: searchText)
        }
    }
}

#Preview {
    PatientsList(selectedPatient: .constant(nil))
}

// MARK: - Calculations

private extension PatientsList {
    @MainActor
    var initialPatients: [Patient] {
        let database = DatabaseController(modelContext: modelContext)
        return database.getModels(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)],
            limit: 100
        )
    }

    @MainActor
    var searchedPatients: [Patient] {
        let predicate = #Predicate<Patient> { patient in
            searchText.isEmpty ? false :
            patient.secondName.localizedStandardContains(searchText) ||
            patient.firstName.localizedStandardContains(searchText) ||
            patient.patronymicName.localizedStandardContains(searchText)
        }
        let database = DatabaseController(modelContext: modelContext)

        return database.getModels(predicate: predicate)
    }
}
