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

    @Query(initialDescriptor) private var patients: [Patient]

    @Binding var selectedPatient: Patient?

    // MARK: - State

    @State private var searchText: String = ""

    // MARK: -

    var body: some View {
        NavigationStack {
            if let searchedPatients = try? modelContext.fetch(searchDescriptor) {
                List(searchText.isEmpty ? patients : searchedPatients) { patient in
                    Button {
                        selectedPatient = patient
                        dismiss()
                    } label: {
                        HStack {
                            Text(patient.fullName)
                            Spacer()
                            Text(patient.phoneNumber)
                        }
                    }
                }
                .listStyle(.inset)
                .searchable(
                    text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .always)
                )
                .sheetToolbar(title: "Выберите пациента")
            }
        }
    }
}

#Preview {
    PatientsList(selectedPatient: .constant(nil))
}

// MARK: - Calculations

private extension PatientsList {
    static var initialDescriptor: FetchDescriptor<Patient> {
        var descriptor = FetchDescriptor<Patient>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        descriptor.fetchLimit = 100

        return descriptor
    }

    var searchDescriptor: FetchDescriptor<Patient> {
        let patientsPredicate = #Predicate<Patient> { patient in
            searchText.isEmpty ? false :
            patient.secondName.localizedStandardContains(searchText) ||
            patient.firstName.localizedStandardContains(searchText) ||
            patient.patronymicName.localizedStandardContains(searchText)
        }
        let descriptor = FetchDescriptor(predicate: patientsPredicate)

        return descriptor
    }
}
