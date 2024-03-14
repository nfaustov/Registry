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
    @State private var user: Doctor? = nil

    // MARK: -

    var body: some View {
        if let user {
            if user.access == .registrar {
                NavigationSplitView {
                    List(Screen.registrarCases, selection: $rootScreen) { screen in
                        HStack {
                            ZStack {
                                Rectangle()
                                    .frame(width: 32, height: 32)
                                    .foregroundStyle(screen.color.gradient)
                                    .clipShape(.rect(cornerRadius: 8, style: .continuous))
                                Image(systemName: screen.imageName)
                                    .foregroundStyle(.white)
                            }
                            Text(screen.title)
                        }
                    }
                    .onChange(of: rootScreen) {
                        coordinator.clearPath()
                    }
                    .navigationTitle("Меню")
                    .navigationSplitViewColumnWidth(220)
                    .scrollBounceBehavior(.basedOnSize)
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
        //            let pricelistItems: [PricelistItem] = load("priceList.json")
        //            for pricelistItem in pricelistItems {
        //                modelContext.insert(pricelistItem)
        //            }
                }
            } else if user.access == .boss {
                NavigationStack(path: $coordinator.path) {
                    coordinator.setRootView(.statistics)
                        .navigationTitle(Screen.statistics.title)
                        .navigationDestination(for: Route.self) { coordinator.destinationView($0) }
                        .sheet(item: $coordinator.sheet) { coordinator.sheetContent($0) }
                }
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
