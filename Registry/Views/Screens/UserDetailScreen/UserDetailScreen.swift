//
//  UserDetailScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 28.03.2024.
//

import SwiftUI

struct UserDetailScreen: View {
    // MARK: - Dependencies

    @Environment(\.user) private var user

    // MARK: -

    var body: some View {
        UserView(user: user)
    }
}

#Preview {
    UserDetailScreen()
}
