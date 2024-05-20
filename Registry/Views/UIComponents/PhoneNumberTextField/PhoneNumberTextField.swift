//
//  PhoneNumberTextField.swift
//  Registry
//
//  Created by Николай Фаустов on 16.01.2024.
//

import SwiftUI

struct PhoneNumberTextField: View {
    // MARK: - Dependencies

    @Binding var text: String
    var focus: (() -> Void)? = nil

    // MARK: - State

    @State private var showKeyboard: Bool = false
    @State private var initialPhoneNumber: String?

    // MARK: -

    var body: some View {
        Button {
            showKeyboard = true
            focus?()
        } label: {
            Text(text)
        }
        .tint(.primary)
        .popover(isPresented: $showKeyboard) {
            popoverContent
        }
        .onAppear {
            if text.isEmpty {
                text = "+7"
            } else {
                initialPhoneNumber = text
            }
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

// MARK: - Subviews

private extension PhoneNumberTextField {
    var popoverContent: some View {
        VStack {
            Form {
                VStack {
                    LabeledContent(text) {
                        Image(systemName: "phone")
                    }
                    .font(.title2)
                    Divider()
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollContentBackground(.hidden)
            .frame(height: 112)

            NumPadView(text: $text)
                .frame(width: 330, height: 360)
                .padding()
                .onChange(of: text) { _, newValue in
                    if newValue.count < 2 {
                        text = "+7"
                    }

                    text = formatter(phoneNumber: text)
                }
                .onDisappear {
                    guard text.count == 18 else {
                        if let initialPhoneNumber {
                            text = initialPhoneNumber
                        } else {
                            text = "+7"
                        }

                        return
                    }
                }
        }
    }
}
