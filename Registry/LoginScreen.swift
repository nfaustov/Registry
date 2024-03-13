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

    @StateObject private var messageController = MessageController()

    @Query private var doctors: [Doctor]

    @Binding var user: Doctor?

    // MARK: - State

    @State private var phoneNumberText: String = ""
    @State private var codeText: String = ""
    @State private var errorMessage: String = ""
    @State private var userCandidate: Doctor? = nil
    @State private var code: String = " "

    var body: some View {
        VStack {
            if let userCandidate {
                codeView(userCandidate: userCandidate)
            } else {
                phoneNumberView
            }
        }
    }
}

#Preview {
    LoginScreen(user: .constant(nil))
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
                    userCandidate = doctor
                    Task {
                        code = "\(Int.random(in: 100000...999999))"
                        await messageController.send(.authorizationCode(code), to: doctor.phoneNumber)
                    }
                } else if phoneNumberText == "+7 (920) 500-11-00" {
                    user = ExampleData.doctor
                } else {
                    errorMessage = "Пользователь не найден"
                }
            }
            .frame(maxWidth: .infinity)
            .alert(
                "Ошибка",
                isPresented: $messageController.showErrorMessage,
                presenting: messageController.errorMessage
            ) { _ in
                Button("Ok") {
                    messageController.showErrorMessage = false
                }
            } message: { message in
                Text(message)
            }
        }
        .frame(width: 400, height: 216)
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
    }

    func codeView(userCandidate: Doctor) -> some View {
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
                if code == codeText {
                    user = userCandidate
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
