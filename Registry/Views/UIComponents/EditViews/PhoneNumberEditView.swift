//
//  PhoneNumberEditView.swift
//  Registry
//
//  Created by Николай Фаустов on 31.03.2024.
//

import SwiftUI
import SwiftData

struct PhoneNumberEditView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    @Binding var person: Person

    // MARK: - State

    @State private var phoneNumberText: String
    @State private var errorMessage: String = ""

    // MARK: -

    init(person: Binding<Person>) {
        _person = person
        _phoneNumberText = State(initialValue: person.wrappedValue.phoneNumber)
    }

    var body: some View {
        Form {
            Section {
                LabeledContent {
                    Button("Сохранить") {
                        if person is Patient, let patient = alreadyExistingPatient(with: phoneNumberText) {
                            errorMessage = "Пациент с таким номером телефона уже существует. (\(patient.fullName))"
                        } else {
                            withAnimation {
                                person.phoneNumber = phoneNumberText
                            }
                        }
                    }
                    .disabled(person.phoneNumber == phoneNumberText || phoneNumberText.count != 18)
                } label: {
                    PhoneNumberTextField(text: $phoneNumberText)
                        .onChange(of: phoneNumberText) {
                            errorMessage = ""
                        }
                }
            } header: {
                Text("Номер телефона")
            } footer: {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    PhoneNumberEditView(person: .constant(ExampleData.patient))
}

// MARK: - Calculations

private extension PhoneNumberEditView {
    func alreadyExistingPatient(with phoneNumber: String) -> Patient? {
        let predicate = #Predicate<Patient> { $0.phoneNumber == phoneNumber }
        let descriptor = FetchDescriptor(predicate: predicate)

        return try? modelContext.fetch(descriptor).first
    }
}
