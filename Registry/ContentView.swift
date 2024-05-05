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

    // MARK: -

    var body: some View {
        if let user = coordinator.user {
            NavigationSplitView {
                VStack {
                    List(user.accessLevel == .boss ? Screen.bossCases : Screen.registrarCases, selection: $rootScreen) { screen in
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
                        .onTapGesture {
                            rootScreen = .userDetail
                        }
                }
                .navigationTitle("Меню")
                .navigationSplitViewColumnWidth(220)
                .scrollBounceBehavior(.basedOnSize)
            } detail: {
                NavigationStack(path: $coordinator.path) {
                    coordinator.setRootView(rootScreen ?? .schedule)
                        .navigationTitle(rootScreen?.title ?? Screen.schedule.title)
                        .navigationDestination(for: Route.self) {
                            coordinator.destinationView($0)
                                .environment(\.user, user)
                        }
                        .sheet(item: $coordinator.sheet) {
                            coordinator.sheetContent($0)
                                .environment(\.user, user)
                        }
                        .environment(\.user, user)
                }
            }
            .navigationSplitViewStyle(.prominentDetail)
//            .task {
//                let paymentModifier = PaymentModifier(modelContainer: modelContext.container)
//                await paymentModifier.execute()
//            }
        } else {
            LoginScreen { coordinator.logIn($0) }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(Coordinator())
        .modelContainer(for: Doctor.self, inMemory: true)
        .previewInterfaceOrientation(.landscapeRight)
}
