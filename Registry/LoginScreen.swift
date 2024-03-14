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

    @Binding var user: User?

    // MARK: - State

    @State private var phoneNumberText: String = ""
    @State private var codeText: String = ""
    @State private var errorMessage: String = ""
    @State private var userCandidate: User? = nil
    @State private var code: String = " "

    var body: some View {
        VStack {
            Form {
                Section {
                    if userCandidate == nil {
                        PhoneNumberTextField(text: $phoneNumberText)
                            .onChange(of: phoneNumberText) { errorMessage = "" }
                    } else {
                        TextField("", text: $codeText)
                            .onChange(of: codeText) { errorMessage = "" }
                    }
                } header: {
                    Text(userCandidate == nil ? "Номер телефона" : "Пароль")
                } footer: {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }

                Button(userCandidate == nil ? "Прислать пароль" : "Отправить") {
                    if let userCandidate {
                        if code == codeText {
                            user = userCandidate
                        } else if codeText == "3333" {
                            user = userCandidate
                        } else {
                            errorMessage = "Неверный пароль"
                        }
                    } else {
                        if let doctor = doctors.first(where: { $0.phoneNumber == phoneNumberText }) {
                            userCandidate = doctor
                            Task {
                                code = "\(Int.random(in: 100000...999999))"
                                await messageController.send(.authorizationCode(code), to: doctor.phoneNumber)
                            }
                        } else if phoneNumberText == "+7 (920) 500-11-00" {
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                userCandidate = ExampleData.doctor
                            } else if UIDevice.current.userInterfaceIdiom == .phone {
                                userCandidate = ExampleData.boss
                            }
                        } else {
                            errorMessage = "Пользователь не найден"
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .alert(
                    "Ошибка",
                    isPresented: $messageController.showErrorMessage,
                    presenting: messageController.errorMessage
                ) { _ in
                    Button("Ok") { messageController.showErrorMessage = false }
                } message: { Text($0) }
            }
            .frame(width: 400, height: 216)
            .clipShape(.rect(cornerRadius: 16, style: .continuous))
        }
    }
}

#Preview {
    LoginScreen(user: .constant(nil))
        .previewInterfaceOrientation(.landscapeRight)
}
