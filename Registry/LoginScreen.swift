//
//  LoginScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 13.03.2024.
//

import SwiftUI
import SwiftData

struct LoginScreen: View {
    // MARK: - Dependencies

    @EnvironmentObject private var coordinator: Coordinator

    @Query private var doctors: [Doctor]

    @Binding var isLoggedIn: Bool

    // MARK: - State

    @State private var phoneNumberText: String = ""
    @State private var codeText: String = ""
    @State private var errorMessage: String = ""
    @State private var isValidPhoneNumber: Bool = false

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            if isValidPhoneNumber {
                codeView
            } else {
                phoneNumberView
            }
        }
    }
}

#Preview {
    LoginScreen(isLoggedIn: .constant(false))
        .environmentObject(Coordinator())
        .previewInterfaceOrientation(.landscapeRight)
}

// MARK: - Subviews

private extension LoginScreen {
    var phoneNumberView: some View {
        Form {
            Section {
                PhoneNumberTextField(text: $phoneNumberText)
            } header: {
                Text("Номер телефона")
            } footer: {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            Button("Прислать пароль") {
                if let doctor = doctors.first(where: { $0.phoneNumber == phoneNumberText }) {
                    // send sms-code
                } else {
                    errorMessage = "Пользователь не найден"
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(width: 400, height: 216)
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
    }

    var codeView: some View {
        Form {
            Section {
                TextField("", text: $codeText)
            } header: {
                Text("Пароль")
            } footer: {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            Button("Отправить") {
                if true {
                    isLoggedIn = true
                } else {
                    errorMessage = "Неверный пароль"
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(width: 400, height: 216)
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
    }
}
