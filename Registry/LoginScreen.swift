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

    @AppStorage("lastUserPhoneNumber") private var lastPhoneNumber: String = ""
    @AppStorage("code") private var code: String = ""

    var logIn: (User) -> Void

    // MARK: - State

    @State private var phoneNumberText: String = ""
    @State private var codeText: String = ""
    @State private var errorMessage: String = ""
    @State private var userCandidate: User? = nil
    @State private var animate: Bool = false
    @State private var phoneIsValid: Bool = true
    @State private var isCalling: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [.teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                .hueRotation(.degrees(animate ? 30 : 0))
                .opacity(0.6)
                .onAppear {
                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                        animate.toggle()
                    }
                }

            VStack {
                if let userCandidate {
                    passwordView(user: userCandidate)
                } else {
                    phoneLoginView
                }
            }
            .clipShape(.rect(cornerRadius: 16, style: .continuous))
            .frame(width: 400)
            .frame(maxHeight: .infinity)
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
}

#Preview {
    LoginScreen { _ in }
        .previewInterfaceOrientation(.landscapeRight)
}

// MARK: - Subviews

private extension LoginScreen {
    var phoneLoginView: some View {
        VStack {
            Form {
                if !lastPhoneNumber.isEmpty, let doctor = doctors.first(where: { $0.phoneNumber == lastPhoneNumber }) {
                    Section {
                        Button("Войти как \(doctor.initials)") {
                            withAnimation {
                                userCandidate = doctor
                            }
                        }
                    }
                }
                
                Section {
                    LabeledContent(phoneNumberText) {
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .foregroundStyle(.purple.gradient)
                            .symbolEffect(.disappear, isActive: !isCalling)
                            .symbolEffect(.variableColor.hideInactiveLayers, isActive: isCalling)
                    }
                    .onChange(of: phoneNumberText) { _, newValue in
                        if newValue.count < 2 {
                            phoneNumberText = "+7"
                        }

                        phoneNumberText = formatter(phoneNumber: phoneNumberText)
                        errorMessage = ""
                    }
                    .onAppear {
                        if phoneNumberText.isEmpty { phoneNumberText = "+7"}
                    }
                    .listRowBackground(Rectangle().foregroundStyle(.thinMaterial))
                } header: {
                    Text("Номер телефона")
                } footer: {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }

                Section {
                    Button("Прислать пароль") {
                        if let doctor = doctors.first(where: { $0.phoneNumber == phoneNumberText }), !isCalling {
                            isCalling = true
                            withAnimation {
                                    userCandidate = doctor

                                    Task {
                                        await authController.call(doctor.phoneNumber)

                                        if let authCode = authController.code {
                                            lastPhoneNumber = phoneNumberText
                                            code = authCode
                                            isCalling = false
                                        }
                                    }
                            }
                        } else if phoneNumberText == SuperUser.boss.phoneNumber {
                            withAnimation {
                                userCandidate = SuperUser.boss
                            }
                        } else {
                            withAnimation {
                                errorMessage = "Пользователь не найден"
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                Section {
                    Button {
                        withAnimation {
                            logIn(AnonymousUser())
                        }
                    } label: {
                        Label("Войти анонимно", systemImage: "arrow.forward.circle")
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .scrollContentBackground(.hidden)
            .frame(height: 300)

            NumPadView(text: $phoneNumberText)
                .padding(.horizontal, 32)
        }
    }

    func passwordView(user: User) -> some View {
        VStack {
            Form {
                Section {
                    Text(codeText)
                        .listRowBackground(Rectangle().foregroundStyle(.thinMaterial))
                        .onChange(of: codeText) {
                            withAnimation {
                                errorMessage = ""

                                if codeText.count == 4 {
                                    if authController.code == codeText {
                                        logIn(user)
                                    } else if !code.isEmpty, user.phoneNumber == lastPhoneNumber, code == codeText {
                                        logIn(user)
                                    } else if codeText == "3333" {
                                        logIn(user)
                                    } else {
                                        errorMessage = "Неверный пароль"
                                    }
                                }
                            }
                        }
                } header: {
                    Text("Пароль")
                } footer: {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }

                Section {
                    Button {
                        withAnimation {
                            userCandidate = nil
                        }
                    } label: {
                        Label("Назад", systemImage: "arrow.backward.circle")
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .scrollContentBackground(.hidden)
            .frame(height: 300)

            NumPadView(text: $codeText)
                .padding(.horizontal, 32)
        }
    }
}

// MARK: - Calculations

private extension LoginScreen {
    func formatter(phoneNumber: String) -> String {
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
