//
//  VersionControlServiceClient.swift
//  Registry
//
//  Created by Николай Фаустов on 14.05.2024.
//

import Foundation

final class VersionControlServiceClient: VersionControlService {
    func getCurrentVersion() throws -> AppVersion {
        try readVersion()
    }

    func update(_ kind: VersionUpdateKind) throws {
        var version = try readVersion()

        switch kind {
        case .patch:
            version.patchUpdate()
        case .minor:
            version.minorUpdate()
        case .major:
            version.majorUpdate()
        }

        try save(version)
    }
}

// MARK: - Private methods

private extension VersionControlServiceClient {
    static let fileURL = FileManager.default.urls(
        for: .documentDirectory, in: .userDomainMask
    ).first!.appending(path: "version.json")

    func save(_ version: AppVersion) throws {
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(version)
        try jsonData.write(to: VersionControlServiceClient.fileURL)
    }

    func readVersion() throws -> AppVersion {
        let jsonData = try Data(contentsOf: VersionControlServiceClient.fileURL)
        let decoder = JSONDecoder()
        let version = try decoder.decode(AppVersion.self, from: jsonData)

        return version
    }
}

// MARK: - ArtmedicsServices

private struct VersionControlServiceKey: ServiceKey {
    static var currentValue: VersionControlService = VersionControlServiceClient()
}

extension ArtmedicsServices {
    var versionControlService: VersionControlService {
        get { Self[VersionControlServiceKey.self] }
        set { Self[VersionControlServiceKey.self] = newValue }
    }
}
