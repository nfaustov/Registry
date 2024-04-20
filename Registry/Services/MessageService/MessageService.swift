//
//  MessageService.swift
//  Registry
//
//  Created by Николай Фаустов on 13.03.2024.
//

import Foundation

protocol MessageService {
    func sendMessage(_ message: Message) async throws -> MessageEntity
}
