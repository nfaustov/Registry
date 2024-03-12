//
//  User.swift
//  Registry
//
//  Created by Николай Фаустов on 12.03.2024.
//

import Foundation

public protocol User {
    var access: UserAccessLevel { get set }
}

public enum UserAccessLevel: Int, Codable, Hashable, CaseIterable, Identifiable {
    case doctor = 1
    case registrar = 2
    case boss = 3

    public var id: Self {
        self
    }
}
