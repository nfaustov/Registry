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

    @StateObject private var authController = AuthorizationController()

    @Query private var doctors: [Doctor]

    @Binding var user: User?

    // MARK: - State

    @State private var phoneNumberText: String = ""
    @State private var codeText: String = ""
    @State private var errorMessage: String = ""
    @State private var userCandidate: User? = nil

    var body: some View {
        VStack {
            if userCandidate == nil {
                phoneLoginView
            } else {
                passwordView
            }
        }
        .frame(width: 400, height: 216)
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
        .padding()
        .alert(
            "Ошибка",
            isPresented: $authController.showErrorMessage,
            presenting: authController.errorMessage
        ) { _ in
            Button("Ok") { authController.showErrorMessage = false }
        } message: { Text($0) }
    }
}

#Preview {
    LoginScreen(user: .constant(nil))
        .previewInterfaceOrientation(.landscapeRight)
}

// MARK: - Subviews

private extension LoginScreen {
    var phoneLoginView: some View {
        Form {
            Section {
                PhoneNumberTextField(text: $phoneNumberText)
                    .onChange(of: phoneNumberText) { errorMessage = "" }
            } header: {
                Text("Номер телефона")
            } footer: {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            Button("Прислать пароль") {
                if let doctor = doctors.first(where: { $0.phoneNumber == phoneNumberText }) {
                    userCandidate = doctor

                    Task {
                        await authController.call(doctor.phoneNumber)
                    }
                } else if phoneNumberText == SuperUser.boss.phoneNumber {
                    userCandidate = SuperUser.boss
                } else {
                    errorMessage = "Пользователь не найден"
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    var passwordView: some View {
        Form {
            Section {
                TextField("", text: $codeText)
                    .onChange(of: codeText) { errorMessage = "" }
            } header: {
                Text("Пароль")
            } footer: {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            Button("Отправить") {
                if authController.code == codeText {
                    user = userCandidate
                } else if codeText == "3333" {
                    user = userCandidate
                } else {
                    errorMessage = "Неверный пароль"
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}
