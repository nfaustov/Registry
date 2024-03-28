//
//  UserView.swift
//  Registry
//
//  Created by Николай Фаустов on 28.03.2024.
//

import SwiftUI

struct UserView: View {
    // MARK: - Dependencies

    let user: User

    // MARK: -

    var body: some View {
        HStack {
            PersonImageView(person: user)
                .frame(width: 52, height: 52, alignment: .top)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(user.initials)
                    .font(.headline)
                    .lineLimit(2)
                Text(user.accessLevel.title)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    UserView(user: ExampleData.doctor)
}
