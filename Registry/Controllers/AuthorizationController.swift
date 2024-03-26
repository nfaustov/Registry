//
//  AuthorizationController.swift
//  Registry
//
//  Created by Николай Фаустов on 26.03.2024.
//

import Foundation

@MainActor final class AuthorizationController: ObservableObject {
    @Service(\.callAuthorization) private var callAuthorization

    @Published private(set) var code: String?
    @Published private(set) var errorMessage: String? {
        didSet {
            showErrorMessage = errorMessage != nil
        }
    }
    @Published var showErrorMessage: Bool = false

    func call(_ phoneNumber: String) async {
        var number = phoneNumber

        for symbol in ["+", " ", "(", ")", "-"] {
            number = number.replacingOccurrences(of: symbol, with: "")
        }

        do {
            let response = try await callAuthorization.call(phoneNumber: number)

            if let code = response.code {
                self.code = code
            } else {
                errorMessage = response.statusText
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
