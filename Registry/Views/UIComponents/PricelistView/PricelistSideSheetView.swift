//
//  PricelistSideSheetView.swift
//  Registry
//
//  Created by Николай Фаустов on 12.04.2024.
//

import SwiftUI

struct PricelistSideSheetView: View {
    // MARK: - State

    @State private var searchText: String = ""
    @State private var isSearching: Bool = false

    // MARK: -

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            SearchBar(text: $searchText, isPresented: $isSearching)
            PricelistView(filterText: searchText, size: .compact, isSearching: $isSearching)
                .listStyle(.plain)
        }
    }
}

#Preview {
    PricelistSideSheetView()
}
