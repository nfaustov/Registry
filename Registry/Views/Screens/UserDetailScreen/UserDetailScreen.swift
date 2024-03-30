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

    @EnvironmentObject private var coordinator: Coordinator

    // MARK: -

    var body: some View {
        UserView(user: user)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        withAnimation {
                            coordinator.logOut()
                        }
                    } label: {
                        Image(systemName: "figure.walk.departure")
                    }
                    .padding()
                }
            }
    }
}

#Preview {
    UserDetailScreen()
        .environmentObject(Coordinator())
}
