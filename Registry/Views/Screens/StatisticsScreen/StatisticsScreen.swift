//
//  StatisticsScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 14.03.2024.
//

import SwiftUI
import Charts
import SwiftData

struct StatisticsScreen: View {
    // MARK: -

    var body: some View {
        List {
            CashboxReportingChart()
            PatientsStatistics()
        }
        .listRowSpacing(8)
    }
}

#Preview {
    StatisticsScreen()
        .preferredColorScheme(.dark)
}
