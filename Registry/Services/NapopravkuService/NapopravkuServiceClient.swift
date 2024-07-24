//
//  NapopravkuServiceClient.swift
//  Registry
//
//  Created by Николай Фаустов on 24.07.2024.
//

import Foundation

final class NapopravkuServiceClient: NapopravkuService {
    private let baseURL = "https://rta-api.napopravku.ru/api/v1"
    private let bearer = "110|Mx21ZKSfhRJNVO3ABufJvq1s1xCsF7JUqZKIpKKm8c8e7869"

    func getAppointmentList() async throws -> AppointmentsListEntity {
        var urlString = "\(baseURL)/appointments"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue(bearer, forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: urlRequest)

        return try JSONDecoder().decode(AppointmentsListEntity.self, from: data)
    }

    func setReceivedAppointment() async throws {
        
    }
}

// MARK: - ArtmedicsServices

private struct NapopravkuServiceKey: ServiceKey {
    static var currentValue: NapopravkuService = NapopravkuServiceClient()
}

extension ArtmedicsServices {
    var napopravkuService: NapopravkuService {
        get { Self[NapopravkuServiceKey.self] }
        set { Self[NapopravkuServiceKey.self] = newValue }
    }
}
