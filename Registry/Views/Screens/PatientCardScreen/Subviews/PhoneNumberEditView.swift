//
//  PhoneNumberEditView.swift
//  Registry
//
//  Created by Николай Фаустов on 31.03.2024.
//

import SwiftUI

struct PhoneNumberEditView: View {
    // MARK: - Dependencies

    @Bindable var patient: Patient

    // MARK: - State

    @State private var phoneNumberText: String

    // MARK: -

    init(patient: Patient) {
        self.patient = patient
        _phoneNumberText = State(initialValue: patient.phoneNumber)
    }

    var body: some View {
        Form {
            Section("Номер телефона") {
                LabeledContent {
                    Button("Сохранить") {
                        withAnimation {
                            patient.phoneNumber = phoneNumberText
                        }
                    }
                    .disabled(patient.phoneNumber == phoneNumberText || phoneNumberText.count != 18)
                } label: {
                    PhoneNumberTextField(text: $phoneNumberText)
                }
            }
        }
    }
}

#Preview {
    PhoneNumberEditView(patient: ExampleData.patient)
}
