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
            .padding(8)
            VStack {
                
            }
            .frame(width: 700)
        }
        .background(Color(.secondarySystemBackground))
    }
}

#Preview {
    DashboardScreen()
}
