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
    @State private var isSearching: Bool = false

    // MARK: -

    var body: some View {
        PricelistView(filterText: searchText, selectedPricelistItem: $selectedPricelistItem, isSearching: $isSearching)
            .searchable(text: $searchText, isPresented: $isSearching)
            .catalogToolbar { coordinator.present(.createPricelistItem) }
            .sheet(item: $selectedPricelistItem) { PricelistItemView(pricelistItem: $0) }
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
