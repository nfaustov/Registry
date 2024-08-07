//
//  DashboardScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 06.06.2024.
//

import SwiftUI

struct DashboardScreen: View {
    // MARK: - Dependencies

    @EnvironmentObject private var coordinator: Coordinator

    // MARK: - State

    @State private var date: Date = .now
    @State private var selectedPeriod: StatisticsPeriod = .day

    // MARK: -

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: -12) {
                AccountsView()
                StatisticsPeriodView(date: $date, selectedPeriod: $selectedPeriod)
                    .padding(.trailing, 4)
            }
            .frame(height: 60)

            HStack(spacing: 4) {
                VStack(spacing: 4) {
                    PatientsReportingView(date: date, selectedPeriod: selectedPeriod)
                    PricelistItemsReportingView(date: date, selectedPeriod: selectedPeriod)
                }

                VStack(spacing: 4) {
                    IncomeReportingView(date: date, selectedPeriod: selectedPeriod)
                    ExpenseReportingView(date: date, selectedPeriod: selectedPeriod)
                }

                VStack(spacing: 4) {
                    DoctorsReportingView(date: date, selectedPeriod: selectedPeriod)
                    RegistrarsReportingView(date: date, selectedPeriod: selectedPeriod)
                }
            }
            .padding(4)
        }
    }
}

#Preview {
    DashboardScreen()
}
