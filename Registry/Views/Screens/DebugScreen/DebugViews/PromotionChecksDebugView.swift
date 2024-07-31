//
//  PromotionChecksDebugView.swift
//  Registry
//
//  Created by Николай Фаустов on 31.07.2024.
//

import SwiftUI
import SwiftData

struct PromotionChecksDebugView: View {

    @Query private var checks: [Check]

    var body: some View {
        List(checks.filter { $0.promotion != nil }) { check in
            HStack {
                DateText(check.payment?.date ?? .now, format: .date)
                Text(check.appointments?.first?.patient?.initials ?? "")
                Text(check.promotion?.title ?? "")
            }
        }
    }
}

#Preview {
    PromotionChecksDebugView()
}

// MARK: - Calculations

private extension PromotionChecksDebugView {
    
}
