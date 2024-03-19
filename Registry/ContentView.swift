//
//  ContentView.swift
//  Registry
//
//  Created by Николай Фаустов on 22.12.2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // MARK: - Dependencies

//    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject private var coordinator: Coordinator

    // MARK: - State

    @State private var rootScreen: Screen? = .schedule
    @State private var user: User? = nil

    // MARK: -

    var body: some View {
        if let user {
            NavigationSplitView {
                if user.accessLevel == .registrar {
                    RegistrarSidebar(rootScreen: $rootScreen)
                } else if user.accessLevel == .boss {
                    IndicatorsList(rootScreen: $rootScreen)
                }
            } detail: {
                NavigationStack(path: $coordinator.path) {
                    coordinator.setRootView(rootScreen ?? .schedule)
                        .navigationTitle(rootScreen?.title ?? Screen.schedule.title)
                        .navigationDestination(for: Route.self) { coordinator.destinationView($0) }
                        .sheet(item: $coordinator.sheet) { coordinator.sheetContent($0) }
                        .environmentObject(UserController(user: user))
                }
            }
            .navigationSplitViewStyle(.prominentDetail)
            .onAppear {
//                    let pricelistItems: [PricelistItem] = load("priceList.json")
//                    for pricelistItem in pricelistItems {
//                        modelContext.insert(pricelistItem)
//                    }
            }
        } else {
            LoginScreen(user: $user)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(Coordinator())
        .modelContainer(for: Doctor.self, inMemory: true)
        .previewInterfaceOrientation(.landscapeRight)
}
