//
//  MedicalServicesScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 23.01.2024.
//

import SwiftUI

struct MedicalServicesScreen: View {
    // MARK: - Dependencies

    @EnvironmentObject private var coordinator: Coordinator

    // MARK: - State

    @State private var searchText: String = ""
    @State private var selectedPricelistItem: PricelistItem?

    // MARK: -

    var body: some View {
        PricelistView(filterText: searchText, selectedPricelistItem: $selectedPricelistItem)
            .searchable(text: $searchText)
            .catalogToolbar { coordinator.present(.createPricelistItem) }
            .sheet(item: $selectedPricelistItem) { item in
                Text(item.title)
            }
    }
}

#Preview {
    NavigationStack {
        MedicalServicesScreen()
            .environmentObject(Coordinator())
            .navigationTitle("Услуги")
    }
    .previewInterfaceOrientation(.landscapeRight)
}
