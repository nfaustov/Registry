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
//    @Query private var pricelistItems: [PricelistItem]
//    @Query private var schedules: [DoctorSchedule]
//    @Query private var doctors: [Doctor]
//    @Query private var patients: [Patient]
//    @Query private var reports: [Report]

    @EnvironmentObject private var coordinator: Coordinator

    // MARK: - State

    @State private var rootScreen: Screen? = .schedule
    @State private var user: User? = nil

    // MARK: -

    var body: some View {
        if let user {
            NavigationSplitView {
                VStack {
                    List(user.accessLevel == .boss ? Screen.allCases : Screen.registrarCases, selection: $rootScreen) { screen in
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

                    Spacer()

                    UserView(user: user)
                        .padding()
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
                        .preferredColorScheme(user.accessLevel == .boss ? .dark : .none)
                        .environment(\.user, user)
                }
            }
            .navigationSplitViewStyle(.prominentDetail)
            .onAppear {
//                schedules.forEach { modelContext.delete($0) }
//                doctors.forEach { modelContext.delete($0) }
//                patients.forEach { modelContext.delete($0) }
//                reports.forEach { modelContext.delete($0) }
//                pricelistItems.forEach { modelContext.delete($0) }
                
//                let pricelistItems: [PricelistItem] = load("priceList.json")
//                for pricelistItem in pricelistItems {
//                    modelContext.insert(pricelistItem)
//                }
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
