//
//  IndicatorsList.swift
//  Registry
//
//  Created by Николай Фаустов on 19.03.2024.
//

import SwiftUI

struct IndicatorsList: View {
    // MARK: - Dependencies

    @EnvironmentObject private var coordinator: Coordinator

    @Binding var rootScreen: Screen?

    // MARK: -

    var body: some View {
        List(Screen.allCases, selection: $rootScreen) { screen in
            screen.indicatorView
        }
        .listRowSpacing(8)
        .scrollBounceBehavior(.basedOnSize)
    }
}

#Preview {
    IndicatorsList(rootScreen: .constant(nil))
}
