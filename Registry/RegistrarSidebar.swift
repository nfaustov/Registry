//
//  RegistrarSidebar.swift
//  Registry
//
//  Created by Николай Фаустов on 19.03.2024.
//

import SwiftUI

struct RegistrarSidebar: View {
    // MARK: - Dependencies

    @EnvironmentObject private var coordinator: Coordinator

    @Binding var rootScreen: Screen?

    // MARK: -

    var body: some View {
        List(Screen.allCases, selection: $rootScreen) { screen in
            HStack {
                ZStack {
                    Rectangle()
                        .frame(width: 32, height: 32)
                        .foregroundStyle(screen.color.gradient)
                        .clipShape(.rect(cornerRadius: 8, style: .continuous))
                    Image(systemName: screen.imageName)
                        .foregroundStyle(.white)
                }
                Text(screen.title)
            }
        }
        .onChange(of: rootScreen) {
            coordinator.clearPath()
        }
        .navigationTitle("Меню")
        .navigationSplitViewColumnWidth(220)
        .scrollBounceBehavior(.basedOnSize)
    }
}

#Preview {
    RegistrarSidebar(rootScreen: .constant(.schedule))
}
