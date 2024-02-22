//
//  AccountView.swift
//  Registry
//
//  Created by Николай Фаустов on 22.02.2024.
//

import SwiftUI

struct AccountView: View {
    // MARK: - Dependencies

    let value: Double
    let type: PaymentType
    let fraction: Double

    // MARK: -

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .trim(from: fraction + 0.04, to: 0.96)
                    .stroke(stroke, style: .init(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Circle()
                    .trim(from: 0, to: fraction)
                    .stroke(tint, style: .init(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Text(fractionPercent)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .padding(8)
            .frame(height: 60)
            .background(tint.opacity(0.4))
            .background(Color("black"))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading) {
                Text(type.rawValue)
                    .font(.headline)
                Text("\(Int(value)) ₽")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

#Preview {
    AccountView(value: 40013, type: .bank, fraction: 30013 / 68313)
        .previewLayout(.sizeThatFits)
}

// MARK: - Calculations

private extension AccountView {
    var fractionPercent: String {
        let percent = (fraction * 100).rounded()
        return "\(Int(percent)) %"
    }

    var tint: Color {
        switch type {
        case .cash:
            return .orange
        case .bank:
            return .purple
        case .card:
            return .green
        }
    }

    var stroke: Color {
        switch type {
        case .cash:
            return .orange.opacity(0.3)
        case .bank:
            return .purple.opacity(0.3)
        case .card:
            return .green.opacity(0.3)
        }
    }
}
