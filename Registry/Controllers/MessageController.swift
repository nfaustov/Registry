//
//  MessageController.swift
//  Registry
//
//  Created by Николай Фаустов on 13.03.2024.
//

import Foundation

@MainActor final class MessageController: ObservableObject {
    @Service(\.messageService) private var messageService

    @Published private(set) var errorMessage: String?
    @Published private(set) var response: MessageEntity?

    func send(_ message: Message, to phoneNumber: String) async throws {
        var number = phoneNumber

        for symbol in ["+", " ", "(", ")", "-"] {
            number = number.replacingOccurrences(of: symbol, with: "")
        }
        
        do {
            response = try await messageService.sendMessage(phoneNumber: number, message: message)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
