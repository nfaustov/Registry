//
//  VersionControlService.swift
//  Registry
//
//  Created by Николай Фаустов on 14.05.2024.
//

import Foundation

protocol VersionControlService {
    func getCurrentVersion() throws -> AppVersion
    func update(_ kind: VersionUpdateKind) throws
}

enum VersionUpdateKind {
    case patch, minor, major
}
