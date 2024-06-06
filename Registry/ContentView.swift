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

    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject private var coordinator: Coordinator

    // MARK: - State

    @State private var rootScreen: Screen? = .schedule

    // MARK: -

    var body: some View {
        if let user = coordinator.user {
            NavigationSplitView {
                VStack(alignment: .leading) {
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
                .navigationSplitViewColumnWidth(260)
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
//                let descriptor = FetchDescriptor<PricelistItem>()
//                guard let pricelistItems = try? modelContext.fetch(descriptor) else { return }
//                let laboratoryItems = pricelistItems.filter { $0.category == .laboratory }
//                let promotion = Promotion(
//                    title: "INSTA30",
//                    terms: "Скидка 30% на все анализы крови",
//                    discountRate: 0.3,
//                    expirationDate: .now.addingTimeInterval(86_400)
//                )
//                modelContext.insert(promotion)
//                promotion.addPricelistItems(laboratoryItems)
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

//private extension ContentView {
//    func loadData() {
//        let patients: [Patient] = load("patients.json")
//        for patient in patients {
//            modelContext.insert(patient)
//        }
//
//        let doctors: [Doctor] = load("doctors.json")
//        for doctor in doctors {
//            modelContext.insert(doctor)
//        }
//
//        let pricelistItems: [PricelistItem] = load("pricelistItems.json")
//        for pricelistItem in pricelistItems {
//            modelContext.insert(pricelistItem)
//        }
//
//        let basicTreatmentPlanPricelistItem = PricelistItem(id: "ТРИТ-БАЗ", category: .therapy, title: "Годовое обслуживание по лечебному плану БАЗОВЫЙ", price: 6900, costPrice: 6300, fixedAgentFee: 600)
//        basicTreatmentPlanPricelistItem.archived = true
//        modelContext.insert(basicTreatmentPlanPricelistItem)
//        let pregnancyTreatmentPlanPricelistItem = PricelistItem(id: "ТРИТ-БЕРЕМ", category: .therapy, title: "Годовое обслуживание по лечебному плану БЕРЕМЕННОСТЬ", price: 12900, costPrice: 11700, fixedAgentFee: 1200)
//        pregnancyTreatmentPlanPricelistItem.archived = true
//        modelContext.insert(pregnancyTreatmentPlanPricelistItem)
//
//        for pricelistItem in pricelistItems {
//            if pricelistItem.treatmentPlans.contains(.pregnancy) {
//                pricelistItem.treatmentPlans.append(contentsOf: TreatmentPlan.Kind.pregnancyAICases)
//            }
//            if pricelistItem.category == .obstetrics {
//                let pregnancyAICasesIDs = TreatmentPlan.Kind.pregnancyAICases.map { $0.id }
//                if pregnancyAICasesIDs.contains(pricelistItem.id) {
//                    pricelistItem.archived = true
//                }
//            }
//        }
//    }
//}
