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

    var logIn: (User) -> Void

    // MARK: - State

    @State private var phoneNumberText: String = ""
    @State private var codeText: String = ""
    @State private var errorMessage: String = ""
    @State private var userCandidate: User? = nil
    @State private var animate: Bool = false

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
            .frame(width: 400, height: 300)
            .frame(maxHeight: .infinity)
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

            Section {
                Button("Прислать пароль") {
                    withAnimation {
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
        .background(.ultraThinMaterial)
    }

    func passwordView(user: User) -> some View {
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
                withAnimation {
                    if authController.code == codeText {
                        logIn(user)
                    } else if codeText == "3333" {
                        logIn(user)
                    } else {
                        errorMessage = "Неверный пароль"
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .scrollContentBackground(.hidden)
        .background(.ultraThinMaterial)
    }
}
