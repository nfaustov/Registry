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

    @StateObject private var versionController = VersionController()

    @Query private var doctors: [Doctor]

    @AppStorage("lastUser") private var lastUserID: String = ""

    var logIn: (User) -> Void

    // MARK: - State

    @State private var animate: Bool = false
    @State private var selectedRegistrar: Doctor? = nil
    @State private var codeText: String = ""
    @State private var errorMessage: String = ""

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

            Text(versionController.currentVersion?.description ?? versionController.errorMessage ?? "")
                .lineLimit(2)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding()

            VStack {
                Form {
                    Section {
                        LabeledContent("Войти как:") {
                            Menu(selectedRegistrar?.initials ?? "Выберите пользователя") {
                                let registrars = doctors.filter { $0.accessLevel == .registrar }

                                ForEach(registrars) { registrar in
                                    Button(registrar.initials) {
                                        selectedRegistrar = registrar
                                    }
                                }
                            }
                        }
                    }
                    .onAppear {
                        withAnimation {
                            selectedRegistrar = doctors.first(where: { $0.id.uuidString == lastUserID })
                        }
                    }

                    Section {
                        Text(codeText)
                            .listRowBackground(Rectangle().foregroundStyle(.thinMaterial))
                            .onChange(of: codeText) { _, newValue in
                                withAnimation {
                                    errorMessage = ""

                                    if codeText.count >= 7 {
                                        if codeText == "1380000" {
                                            logIn(SuperUser.boss)
                                        } else if let selectedRegistrar, codeText == "\(pass(for: selectedRegistrar.id))" {
                                            lastUserID = selectedRegistrar.id.uuidString
                                            logIn(selectedRegistrar)
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
                }
                .scrollContentBackground(.hidden)
                .frame(height: 300)

                NumPadView(text: $codeText)
                    .frame(height: 400)
            }
            .frame(width: 400)
            .frame(maxHeight: .infinity)
            .padding()
        }
        .onAppear {
//            versionController.updateVersion(.minor)
            versionController.getCurrentVersion()
        }
    }
}

#Preview {
    LoginScreen { _ in }
        .previewInterfaceOrientation(.landscapeRight)
}

private extension LoginScreen {
    func pass(for userID: UUID) -> Int {
        let count = userID.uuidString.count
        let string = userID.uuidString.dropLast(count - 6)

        guard let pass = Int(string, radix: 16) else { fatalError() }

        return pass
    }
}
