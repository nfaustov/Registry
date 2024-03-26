//
//  CallAuthorizationServiceClient.swift
//  Registry
//
//  Created by Николай Фаустов on 26.03.2024.
//

import Foundation

final class CallAuthorizationServiceClient: CallAuthorizationService {
    private let apiID = "77D875DA-CCDF-2E94-624C-FF1117015D6F"

    func call(phoneNumber: String) async throws -> CallAuthorizationEntity {
        guard let url = URL(string: "https://sms.ru/code/call?phone=\(phoneNumber)&ip=-1&api_id=\(apiID)") else {
            throw URLError(.badURL)
        }

        var urlREquest = URLRequest(url: url)
        urlREquest.httpMethod = "POST"

        let (data, _) = try await URLSession.shared.data(for: urlREquest)

        return try JSONDecoder().decode(CallAuthorizationEntity.self, from: data)
    }
}

private struct CallAuthorizationServiceKey: ServiceKey {
    static var currentValue: CallAuthorizationService = CallAuthorizationServiceClient()
}

public extension ArtmedicsServices {
    var callAuthorization: CallAuthorizationService {
        get { Self[CallAuthorizationServiceKey.self] }
        set { Self[CallAuthorizationServiceKey.self] = newValue }
    }
}
