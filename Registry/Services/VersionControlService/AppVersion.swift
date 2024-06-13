//
//  AppVersion.swift
//  Registry
//
//  Created by Николай Фаустов on 14.05.2024.
//

import Foundation

struct AppVersion: Codable {
    private(set) var major: Int
    private(set) var minor: Int
    private(set) var patch: Int
    private(set) var updatedAt: Date
    
    init(_ major: Int, _ minor: Int, _ patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
        updatedAt = .now
    }
    
    var description: String {
        "v\(major).\(minor).\(patch)\n\(DateFormat.dateTime.string(from: updatedAt))"
    }

    mutating func update(_ kind: VersionUpdateKind) {
        switch kind {
        case .patch:
            patch += 1
        case .minor:
            minor += 1
            patch = 0
        case .major:
            major += 1
            minor = 0
            patch = 0
        }

        updatedAt = .now
    }
}
