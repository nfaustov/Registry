//
//  PricelistItemsDebugScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 30.05.2024.
//

import SwiftUI
import SwiftData

struct PricelistItemsDebugScreen: View {
    // MARK: - Dependencies

    @Query private var pricelistItems: [PricelistItem]

    // MARK: - State

    @State private var selectedItem: PricelistItem?

    // MARK: -

    var body: some View {
        let items = pricelistItems.filter { $0.costPrice == 0 }
        List(items) { item in
            Button {
                selectedItem = item
            } label: {
                LabeledContent {
                    Text("\(Int(item.price))")
                } label: {
                    HStack {
                        Text(item.id)
                        Text(item.title)
                    }
                }
            }
        }
        .sheet(item: $selectedItem) { PricelistItemView(pricelistItem: $0) }
    }
}

#Preview {
    PricelistItemsDebugScreen()
}
