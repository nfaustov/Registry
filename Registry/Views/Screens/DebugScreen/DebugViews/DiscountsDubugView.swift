//
//  DiscountsDubugView.swift
//  Registry
//
//  Created by Николай Фаустов on 31.07.2024.
//

import SwiftUI
import SwiftData

struct DiscountsDubugView: View {
    @Query private var checks: [Check]

    var body: some View {
        Text("Скидки за июль \(Int(monthlyDiscountChecks.reduce(0) { $0 + $1.discount }))")

        List(monthlyDiscountChecks) { check in
            LabeledContent{
                HStack {
                    CurrencyText(check.totalPrice)
                    CurrencyText(check.discount)
                }
            } label: {
                DateText(check.payment!.date, format: .date)
            }
        }
    }

    var monthlyDiscountChecks: [Check] {
        let components = Calendar.current.dateComponents([.year, .month], from: .now)
        let date = Calendar.current.date(from: components)

        return checks
            .filter { $0.payment != nil }
            .filter { Calendar.current.date(from: components)! < $0.payment!.date }
            .filter { $0.discount > 0 }
            .sorted(by: { $0.payment!.date < $1.payment!.date })
    }
}

#Preview {
    DiscountsDubugView()
}
