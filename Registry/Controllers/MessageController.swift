//
//  MessageController.swift
//  Registry
//
//  Created by Николай Фаустов on 13.03.2024.
//

import Foundation

@MainActor final class MessageController: ObservableObject {
    @Service(\.messageService) private var messageService

    @Published private(set) var errorMessage: String? {
        didSet {
            showErrorMessage = errorMessage != nil
        }
    }
    @Published private(set) var response: MessageEntity?
    @Published var showErrorMessage: Bool = false

    func send(_ message: Message, to phoneNumber: String) async {
        var number = phoneNumber

        for symbol in ["+", " ", "(", ")", "-"] {
            number = number.replacingOccurrences(of: symbol, with: "")
        }
        
        do {
            response = try await messageService.sendMessage(phoneNumber: number, message: message)
            errorMessage = response?.sms.first?.value.statusText
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
