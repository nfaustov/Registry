//
//  PhoneNumberTextField.swift
//  Registry
//
//  Created by Николай Фаустов on 16.01.2024.
//

import SwiftUI

struct PhoneNumberTextField: View {
    // MARK: Dependencies

    @Binding var text: String

    // MARK: -

    var body: some View {
        TextField("", text: $text)
            .keyboardType(.phonePad)
            .onChange(of: text) { _, newValue in
                if newValue.count < 2 {
                    text = "+7"
                }

                text = formatter(phoneNumber: text)
            }
            .onSubmit {
                guard text.count == 18 else {
                    text = "+7"
                    return
                }
            }
            .onAppear {
                text = "+7"
            }
    }

    private func formatter(phoneNumber: String) -> String {
        let number = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result: String = ""
        var index = number.startIndex
        let mask = "+X (XXX) XXX-XX-XX"

        for character in mask where index < number.endIndex {
            if character == "X" {
                result.append(number[index])
                index = number.index(after: index)
            } else {
                result.append(character)
            }
        }

        return result
    }
}

#Preview {
    PhoneNumberTextField(text: .constant(""))
}
