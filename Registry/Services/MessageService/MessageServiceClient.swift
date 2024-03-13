//
//  MessageServiceClient.swift
//  Registry
//
//  Created by Николай Фаустов on 13.03.2024.
//

import Foundation

final class MessageServiceClient: MessageService {
    private let apiID = "77D875DA-CCDF-2E94-624C-FF1117015D6F"

    func sendMessage(phoneNumber: String, message: Message) async throws -> MessageEntity {
        guard let url = URL(string: "https://sms.ru/sms/send?api_id=\(apiID)&to=\(phoneNumber)&msg=\(message.text)&json=1") else {
            throw URLError(.badURL)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"

        let (data, _) = try await URLSession.shared.data(for: urlRequest)

        return try JSONDecoder().decode(MessageEntity.self, from: data)
    }
}

private struct MessageServiceKey: ServiceKey {
    static var currentValue: MessageService = MessageServiceClient()
}

public extension ArtmedicsServices {
    var messageService: MessageService {
        get { Self[MessageServiceKey.self] }
        set { Self[MessageServiceKey.self] = newValue }
    }
}
