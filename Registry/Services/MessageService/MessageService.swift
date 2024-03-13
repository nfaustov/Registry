//
//  MessageService.swift
//  Registry
//
//  Created by Николай Фаустов on 13.03.2024.
//

import Foundation

public protocol MessageService {
    func sendMessage(phoneNumber: String, message: Message) async throws -> MessageEntity
}
