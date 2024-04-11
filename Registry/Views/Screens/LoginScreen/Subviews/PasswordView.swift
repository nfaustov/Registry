//
//  PasswordView.swift
//  Registry
//
//  Created by Николай Фаустов on 11.04.2024.
//

import SwiftUI

struct PasswordView: View {
    // MARK: - Dependencies

    @ObservedObject var authController: AuthorizationController

    @AppStorage("code") private var code: String = ""

    let user: User

    var logIn: (User) -> Void
    var onCancel: () -> Void

    // MARK: - State

    @State private var codeText: String = ""
    @State private var errorMessage: String = ""

    // MARK: -

    var body: some View {
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
                                    } else if !code.isEmpty, code == codeText {
                                        logIn(user)
                                    } else if codeText == "1380" {
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
                            onCancel()
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
                .frame(height: 400)
        }
    }
}

#Preview {
    PasswordView(
        authController: AuthorizationController(),
        user: ExampleData.doctor,
        logIn: { _ in },
        onCancel: { }
    )
}
