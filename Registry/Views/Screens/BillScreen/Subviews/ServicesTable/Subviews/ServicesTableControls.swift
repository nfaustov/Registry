//
//  ServicesTableControls.swift
//  Registry
//
//  Created by Николай Фаустов on 12.04.2024.
//

import SwiftUI
import SwiftData

struct ServicesTableControls: View {
    // MARK: - Dependencies

    @EnvironmentObject private var coordinator: Coordinator

    @Bindable var check: Check
    @Binding var isPricelistPresented: Bool
    @Binding var predictions: Bool
    @Binding var enabledTreatmentPlan: Bool

    static let now = Date.now

    @Query private var checkTemplates: [CheckTemplate]
    @Query(filter: #Predicate<Promotion> { $0.expirationDate > now }) 
    private var promotions: [Promotion]

    // MARK: -

    var body: some View {
        HStack {
            Menu {
                Section {
                    Button(role: .destructive) {
                        withAnimation {
                            check.services = []
                        }
                    } label: {
                        Label("Очистить", systemImage: "trash")
                    }
                    .disabled(check.services.isEmpty)
                }

                Section {
                    Button {
                        coordinator.present(.createBillTemplate(services: check.services))
                    } label: {
                        Label("Создать шаблон", systemImage: "note.text.badge.plus")
                    }
                    .disabled(check.services.isEmpty)

                    Menu {
                        ForEach(checkTemplates) { template in
                            Button(template.title) {
                                let templateServices = template.getCopy()

                                withAnimation {
                                    check.services.append(contentsOf: templateServices)
                                    check.discount += template.discount
                                }
                            }
                        }
                    } label: {
                        Label("Использовать шаблон", systemImage: "note.text")
                    }
                    .disabled(checkTemplates.isEmpty)
                }

                Section {
                    Menu {
                        ForEach(promotions) { promotion in
                            if check.promotionDiscount(promotion) > 0 {
                                Button {
                                    withAnimation {
                                        check.applyPromotion(promotion)
                                    }
                                } label: {
                                    if check.promotion == promotion {
                                        Label(promotion.title, systemImage: "checkmark.circle")
                                    } else {
                                        Text(promotion.title)
                                    }
                                }
                                .disabled(check.promotion == promotion)
                            }
                        }
                    } label: {
                        Label("Промоакции", systemImage: "giftcard")
                    }
                    .disabled(check.services.contains(where: { $0.treatmentPlanPrice != nil }))
                }
            } label: {
                Label("Действия", systemImage: "ellipsis.circle")
            }
            .disabled(isPricelistPresented || (check.services.isEmpty && checkTemplates.isEmpty))

            Toggle(isOn: $predictions) {
                Label("Предложения", systemImage: "sparkles")
            }
            .padding(.horizontal)
            .toggleStyle(.button)
            .tint(.indigo)

            if let patient = check.appointments?.first?.patient,
               let treatmentPlan = patient.currentTreatmentPlan {
                Toggle(isOn: $enabledTreatmentPlan) {
                    Text("Лечебный план: \(treatmentPlan.kind.rawValue)")
                }
                .padding(.horizontal)
                .toggleStyle(.button)
                .tint(.appBlack)
            }

            Spacer()

            Button {
                withAnimation {
                    isPricelistPresented = true
                }
            } label: {
                HStack {
                    Text("Добавить услуги")
                    Image(systemName: "chevron.right")
                }
            }
        }
    }
}

#Preview {
    ServicesTableControls(
        check: Check(services: []),
        isPricelistPresented: .constant(false),
        predictions: .constant(true),
        enabledTreatmentPlan: .constant(true)
    )
}
