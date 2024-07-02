//
//  MoneyFieldSection.swift
//  Registry
//
//  Created by Николай Фаустов on 27.04.2024.
//

import SwiftUI

struct MoneyFieldSection<Footer: View>: View {
    // MARK: Dependencies

    @Binding var value: Double

    private let titleKey: String
    private var footer: () -> Footer

    // MARK: - State

    @State private var valueText: String = ""
    @State private var showKeyboard: Bool = false

    // MARK: -

    init(_ titleKey: String = "", value: Binding<Double>, @ViewBuilder footer: @escaping (() -> Footer) = { EmptyView() }) {
        _value = value
        self.titleKey = titleKey
        self.footer = footer
    }

    var body: some View {
        Section {
            LabeledContent {
                Image(systemName: "pencil")
            } label: {
                Button {
                    showKeyboard = true
                } label: {
                    CurrencyText(value, unit: false)
                }
                .tint(.primary)
                .popover(isPresented: $showKeyboard) {
                    popoverContent
                }
            }
        } header: {
            if !titleKey.isEmpty {
                Text(titleKey)
            }
        } footer: {
            footer()
        }
    }
}

#Preview {
    MoneyFieldSection(value: .constant(100), footer: { })
}

private extension MoneyFieldSection {
    var popoverContent: some View {
        VStack(alignment: .leading) {
            Form {
                Section {
                    LabeledContent(valueText, value: "₽")
                        .font(.title2)
                        .padding()
                        .listRowBackground(Rectangle().foregroundStyle(.thickMaterial))
                } header: {
                    if !titleKey.isEmpty {
                        Text(titleKey)
                    }
                } footer: {
                    footer()
                        .font(.footnote)
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollContentBackground(.hidden)
            .frame(height: 152)

            NumPadView(text: $valueText)
                .environment(\.numPadStyle, .decimal)
                .frame(width: 330, height: 360)
                .padding()
                .onChange(of: valueText) { _, newValue in
                    value = Double(newValue) ?? 0
                }
        }
    }
}
