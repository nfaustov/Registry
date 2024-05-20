//
//  PredictionsView.swift
//  Registry
//
//  Created by Николай Фаустов on 20.05.2024.
//

import SwiftUI

struct PredictionsView: View {
    // MARK: - Dependencies

    let predictions: [PricelistItem.Snapshot]
    var addToCheckAction: (PricelistItem.Snapshot) -> Void

    var body: some View {
        VStack {
            ForEach(predictions) { item in
                Button {
                    withAnimation {
                        addToCheckAction(item)
                    }
                } label: {
                    LabeledCurrency(item.title, value: item.price)
                }
                .buttonStyle(PredictionButton())
            }
        }
    }
}

#Preview {
    PredictionsView(predictions: [ExampleData.pricelistItem.snapshot], addToCheckAction: { item in })
}

struct PredictionButton: ButtonStyle {
    // MARK: - Dependencies

    @Environment(\.isEnabled) private var isEnabled

    // MARK: -

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote)
            .foregroundStyle(.indigo)
            .padding(8)
            .background(.indigo.opacity(configuration.isPressed ? 0.5 : 0.2))
            .clipShape(.rect(cornerRadius: 8, style: .continuous))
            .padding(.horizontal)
            .saturation(isEnabled ? 1 : 0)
            .opacity(isEnabled ? 1 : 0.4)
    }
}
