//
//  PricelistDebugView.swift
//  Registry
//
//  Created by Николай Фаустов on 16.05.2024.
//

import SwiftUI
import SwiftData

struct PricelistDebugView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    // MARK: - State

    @State private var pricelistItems: [PricelistItem] = []

    // MARK: -

    var body: some View {
        List(pricelistItems) { item in
            LabeledContent(item.id, value: item.title)
        }
    }
}

#Preview {
    PricelistDebugView()
}
