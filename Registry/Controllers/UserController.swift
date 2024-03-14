//
//  UserController.swift
//  Registry
//
//  Created by Николай Фаустов on 13.03.2024.
//

import Foundation

final class UserController: ObservableObject {
    @Published private(set) var user: User

    init(user: User) {
        self.user = user
    }
}
