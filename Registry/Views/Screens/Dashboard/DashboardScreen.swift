//
//  DashboardScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 06.06.2024.
//

import SwiftUI

struct DashboardScreen: View {
    var body: some View {
        HStack {
            VStack(spacing: 4) {
                PatientsReportingView()
                PricelistItemsReportingView()
            }
            .frame(width: 400)

            VStack(spacing: 4) {
                LedgerReportingView()
                    .frame(maxWidth: .infinity)
            }

            VStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .foregroundStyle(.white)
            }
            .frame(width: 400)
        }
        .background(Color(.secondarySystemBackground))
    }
}

#Preview {
    DashboardScreen()
}
