//
//  AppVersion.swift
//  Registry
//
//  Created by Николай Фаустов on 14.05.2024.
//

import Foundation

struct AppVersion {
    private let major: Int
    private let minor: Int
    private let patch: Int
    private let date: Date

    init(_ major: Int, _ minor: Int, _ patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
        date = .now
    }

    var description: String {
        "v\(major).\(minor).\(patch)\n\(DateFormat.dateTime.string(from: date))"
    }
}
