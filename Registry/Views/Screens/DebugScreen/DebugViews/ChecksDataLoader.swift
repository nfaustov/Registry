//
//  ChecksDataloader.swift
//  Registry
//
//  Created by Николай Фаустов on 16.05.2024.
//

import SwiftUI
import SwiftData

struct ChecksDataLoader: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    // MARK: - State

    @State private var pricelistItems: [PricelistItem] = []
    @State private var showActivity: Bool = false
    @State private var json: Data? = nil

    // MARK: -

    var body: some View {
        Button {
            showActivity = true
        } label: {
            if json != nil {
                Text("Press me")
            } else {
                CircularProgressView()
            }
        }
        .disabled(json == nil)
        .task {
            let controller = ChecksController(modelContainer: modelContext.container)
            json = try? await controller.getCorrelationsJSON()
        }
        .sheet(isPresented: $showActivity) {
            if let json {
                ActivityView(items: [json])
            }
        }
    }
}

#Preview {
    ChecksDataLoader()
}
