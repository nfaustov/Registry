//
//  IndicatorsScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 19.03.2024.
//

import SwiftUI

struct IndicatorsScreen: View {
    // MARK: -

    var body: some View {
        Form {
            CashboxReportingView()
            PatientsChart()
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

#Preview {
    IndicatorsScreen()
}
