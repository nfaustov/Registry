//
//  PassportDetailView.swift
//  Registry
//
//  Created by Николай Фаустов on 21.02.2024.
//

import SwiftUI
import SwiftData

struct PassportDetailView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    @Bindable var patient: Patient

    // MARK: -

    var body: some View {
        Form {
            Section {
                Picker("Пол", selection: $patient.passport.gender) {
                    ForEach(Gender.allCases, id: \.self) { gender in
                        Text(gender.rawValue.capitalized)
                    }
                }

                DatePicker("Дата рождения", selection: $patient.passport.birthday, displayedComponents: .date)
            } header: {
                Text("Дополнительные данные")
            }

            Section {
                TextField("Серия/Номер", text: $patient.passport.seriesNumber)
                    .onChange(of: patient.passport.seriesNumber) {
                        patient.passport.seriesNumber = formatter(seriesNumberText: patient.passport.seriesNumber)
                    }
                TextField("Кем выдан", text: $patient.passport.authority)
                    .onChange(of: patient.passport.authority) {
                        patient.passport.authority = patient.passport.authority.uppercased()
                    }
                DatePicker("Дата выдачи", selection: $patient.passport.issueDate, displayedComponents: .date)
            } header: {
                Text("Паспорт")
            }
        }
    }
}

#Preview {
    PassportDetailView(patient: ExampleData.patient)
}

// MARK: - Calculations

private extension PassportDetailView {
    func formatter(seriesNumberText: String) -> String {
        let text = seriesNumberText.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result: String = ""
        var index = text.startIndex
        let mask = "XXXX XXXXXX"

        for character in mask where index < text.endIndex {
            if character == "X" {
                result.append(text[index])
                index = text.index(after: index)
            } else {
                result.append(character)
            }
        }

        return result
    }
}
