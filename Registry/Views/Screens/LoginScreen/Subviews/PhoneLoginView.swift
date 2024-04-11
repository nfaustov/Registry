//
//  PhoneLoginView.swift
//  Registry
//
//  Created by Николай Фаустов on 11.04.2024.
//

import SwiftUI
import SwiftData

struct PhoneLoginView: View {
    // MARK: - Dependencies

    @ObservedObject var authController: AuthorizationController

    @Query private var doctors: [Doctor]

    @AppStorage("lastUserPhoneNumber") private var lastPhoneNumber: String = ""
    @AppStorage("code") private var code: String = ""

    @Binding var userCandidate: User?

    var logIn: (User) -> Void

    // MARK: - State

    @State private var phoneNumberText: String = ""
    @State private var isCalling: Bool = false
    @State private var errorMessage: String = ""

    // MARK: -

    var body: some View {
        VStack {
            Form {
                if !lastPhoneNumber.isEmpty, 
                    let doctor = doctors.first(where: { $0.phoneNumber == lastPhoneNumber }) {
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

                            Task {
                                await authController.call(doctor.phoneNumber)

                                if let authCode = authController.code {
                                    lastPhoneNumber = phoneNumberText
                                    code = authCode
                                }
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                                if !authController.showErrorMessage {
                                    withAnimation {
                                        isCalling = false
                                        userCandidate = doctor
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
                .frame(height: 400)
        }
    }
}

#Preview {
    PhoneLoginView(
        authController: AuthorizationController(),
        userCandidate: .constant(ExampleData.doctor),
        logIn: { _ in }
    )
}

// MARK: - Calculations

private extension PhoneLoginView {
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
