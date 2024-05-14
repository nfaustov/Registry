//
//  VersionController.swift
//  Registry
//
//  Created by Николай Фаустов on 14.05.2024.
//

import Foundation

final class VersionController: ObservableObject {
    @Service(\.versionControlService) private var versionControlService

    @Published private(set) var currentVersion: AppVersion?
    @Published private(set) var errorMessage: String?

    func getCurrentVersion() {
        do {
            currentVersion = try versionControlService.getCurrentVersion()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateVersion(_ kind: VersionUpdateKind) {
        do {
            try versionControlService.update(kind)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
