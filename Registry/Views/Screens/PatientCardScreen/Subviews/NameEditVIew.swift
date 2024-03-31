//
//  NameEditVIew.swift
//  Registry
//
//  Created by Николай Фаустов on 31.03.2024.
//

import SwiftUI

struct NameEditVIew: View {
    // MARK: - Dependencies

    @Bindable var patient: Patient

    // MARK: -

    var body: some View {
        Form {
            Section("Фамилия") {
                TextField("Фамилия", text: $patient.secondName)
            }

            Section("Имя") {
                TextField("Имя",text: $patient.firstName)
            }

            Section("Отчество") {
                TextField("Отчество",text: $patient.patronymicName)
            }
        }
    }
}

#Preview {
    NameEditVIew(patient: ExampleData.patient)
}
