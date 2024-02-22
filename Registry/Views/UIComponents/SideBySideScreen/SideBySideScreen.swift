//
//  SideBySideScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 16.01.2024.
//

import SwiftUI

struct SideBySideScreen<Sidebar: View, Detail: View>: View {
    // MARK: - Dependecies

    let sidebarTitle: String
    let detailTitle: String
    @ViewBuilder let sidebar: () -> Sidebar
    @ViewBuilder let detail: () -> Detail

    // MARK: -

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text(sidebarTitle)
                    .font(.largeTitle).bold()
                    .padding(.horizontal)

                Form {
                    sidebar()
                }
                .scrollBounceBehavior(.basedOnSize)
                .frame(width: 400)
            }

            Divider()
                .ignoresSafeArea()

            VStack {
                Text(detailTitle)
                    .font(.headline)
                    .padding()

                detail()
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 16))
            }
            .padding()
            .ignoresSafeArea()
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SideBySideScreen(
            sidebarTitle: "SidebarTitle",
            detailTitle: "DetailTitle"
        ) {
            Text("sidebar")
                .frame(width: 400)
        } detail: {
            HStack {
                Text("detail")
                    .padding()
                Spacer()
            }
        }
    }
}
