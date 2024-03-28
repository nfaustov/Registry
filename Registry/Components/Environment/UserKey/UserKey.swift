//
//  UserKey.swift
//  Registry
//
//  Created by Николай Фаустов on 28.03.2024.
//

import SwiftUI

private struct UserKey: EnvironmentKey {
    static let defaultValue: User = AnonymousUser()
}

extension EnvironmentValues {
    var user: User {
        get { self[UserKey.self] }
        set { self[UserKey.self] = newValue }
    }
}
