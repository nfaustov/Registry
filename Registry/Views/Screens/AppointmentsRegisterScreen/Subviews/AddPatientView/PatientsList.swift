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

    @Query private var patients: [Patient]

    @Binding var selectedPatient: Patient?

    // MARK: - State

    @State private var searchText: String = ""

    // MARK: -

    var body: some View {
        NavigationStack {
            List(patients) { patient in
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

#Preview {
    PatientsList(selectedPatient: .constant(nil))
}
