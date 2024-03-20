//
//  IndicatorsList.swift
//  Registry
//
//  Created by Николай Фаустов on 19.03.2024.
//

import SwiftUI

struct IndicatorsList: View {
    // MARK: - Dependencies

    @Binding var rootScreen: Screen?

    var body: some View {
        List(Screen.allCases) { screen in
            switch screen {
            case .schedule:
                EmptyView()
            case .cashbox:
                CashboxReportingChart()
            case .specialists:
                EmptyView()
            case .patients:
                PatientsStatistics(rootScreen: $rootScreen)
            case .medicalServices:
                EmptyView()
            }
        }
        .listRowSpacing(8)
        .scrollBounceBehavior(.basedOnSize)
        .navigationTitle("Индикаторы")
    }
}

#Preview {
    IndicatorsList(rootScreen: .constant(nil))
}
