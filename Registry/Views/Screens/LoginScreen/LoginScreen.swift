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

    var logIn: (User) -> Void

    // MARK: - State

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
                    PasswordView(
                        authController: authController,
                        user: userCandidate,
                        logIn: logIn,
                        onCancel: { self.userCandidate = nil }
                    )
                } else {
                    PhoneLoginView(
                        authController: authController,
                        userCandidate: $userCandidate,
                        logIn: logIn
                    )
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
