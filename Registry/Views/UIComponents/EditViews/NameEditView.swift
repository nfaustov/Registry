//
//  NameEditView.swift
//  Registry
//
//  Created by Николай Фаустов on 01.04.2024.
//

import SwiftUI

struct NameEditView: View {
    // MARK: - Dependencies

    @Binding var person: Person

    // MARK: -

    var body: some View {
        Form {
            Section("Фамилия") {
                TextField("Фамилия", text: $person.secondName)
            }

            Section("Имя") {
                TextField("Имя",text: $person.firstName)
            }

            Section("Отчество") {
                TextField("Отчество",text: $person.patronymicName)
            }
        }
    }
}

#Preview {
    NameEditView(person: .constant(ExampleData.patient))
}
