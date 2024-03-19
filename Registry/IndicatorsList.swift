//
//  IndicatorsList.swift
//  Registry
//
//  Created by Николай Фаустов on 19.03.2024.
//

import SwiftUI

struct IndicatorsList: View {

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
                PatientsStatistics()
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
    IndicatorsList()
}
