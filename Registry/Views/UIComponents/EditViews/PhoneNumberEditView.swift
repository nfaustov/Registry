//
//  PhoneNumberEditView.swift
//  Registry
//
//  Created by Николай Фаустов on 31.03.2024.
//

import SwiftUI

struct PhoneNumberEditView: View {
    // MARK: - Dependencies

    @Binding var person: Person

    // MARK: - State

    @State private var phoneNumberText: String

    // MARK: -

    init(person: Binding<Person>) {
        _person = person
        _phoneNumberText = State(initialValue: person.wrappedValue.phoneNumber)
    }

    var body: some View {
        Form {
            Section("Номер телефона") {
                LabeledContent {
                    Button("Сохранить") {
                        withAnimation {
                            person.phoneNumber = phoneNumberText
                        }
                    }
                    .disabled(person.phoneNumber == phoneNumberText || phoneNumberText.count != 18)
                } label: {
                    PhoneNumberTextField(text: $phoneNumberText)
                }
            }
        }
    }
}

#Preview {
    PhoneNumberEditView(person: .constant(ExampleData.patient))
}
