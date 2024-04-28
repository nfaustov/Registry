//
//  MoneyField.swift
//  Registry
//
//  Created by Николай Фаустов on 27.04.2024.
//

import SwiftUI

struct MoneyField: View {
    // MARK: Dependencies

    @Binding var value: Double

    // MARK: - State

    @State private var valueText: String = ""
    @State private var showKeyboard: Bool = false

    // MARK: -

    var body: some View {
        Button("\(Int(value))") {
            showKeyboard = true
        }
        .tint(.primary)
        .popover(isPresented: $showKeyboard, arrowEdge: .bottom) {
            VStack(spacing: 0) {
                Form {
                    Section {
                        LabeledContent(valueText, value: "₽")
                            .font(.title)
                            .padding()
                            .listRowBackground(Rectangle().foregroundStyle(.thickMaterial))
                    }
                }
                .scrollContentBackground(.hidden)
                .frame(height: 140)

                NumPadView(text: $valueText)
                    .frame(width: 300, height: 360)
                    .padding()
                    .onChange(of: valueText) { _, newValue in
                        value = Double(newValue) ?? 0
                    }
            }
        }
    }
}

#Preview {
    MoneyField(value: .constant(100))
}
