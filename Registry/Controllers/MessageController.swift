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

    func send(_ message: Message) async {
        do {
            response = try await messageService.sendMessage(message)
            errorMessage = response?.sms.first?.value.statusText
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
