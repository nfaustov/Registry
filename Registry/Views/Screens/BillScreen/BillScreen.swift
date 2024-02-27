//
//  BillScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 26.02.2024.
//

import SwiftUI
import SwiftData

struct BillScreen: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject private var coordinator: Coordinator

    @Query private var billTemplates: [BillTemplate]

    private let appointment: PatientAppointment

    // MARK: - State

    @State private var bill: Bill
    @State private var addServices: Bool = false
    @State private var includeBalance: Bool = false
    @State private var isCompleted = false
    @State private var searchText: String = ""

    // MARK: -

    init(appointment: PatientAppointment) {
        self.appointment = appointment
        if let patient = appointment.patient,
           let visit = patient.visits.first(where: { $0.visitDate == appointment.scheduledTime }),
           let bill = visit.bill {
            _bill = State(initialValue: bill)
        } else {
            _bill = State(initialValue: Bill(services: []))
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            if let patient = appointment.patient {
                HStack {
                    Text(patient.fullName)
                        .font(.title3)
                        .padding(.horizontal)

                    Spacer()

                    if patient.balance != 0 {
                        Toggle("Баланс: \(Int(patient.balance)) ₽", isOn: $includeBalance.animation(.linear(duration: 0.12)))
                            .foregroundColor(patient.balance < 0 ? .red : .primary)
                            .frame(width: 220)
                    }
                }
                .padding(.horizontal)
            }

            VStack(spacing: 0) {
                if let doctor = appointment.schedule?.doctor {
                    ServicesTable(bill: $bill, doctor: doctor, editMode: addServices)
                }

                HStack {
                    Menu {
                        Section {
                            Button(role: .destructive) {
                                withAnimation {
                                    bill.services = []
                                    bill.discount = 0
                                }
                            } label: {
                                Label("Очистить", systemImage: "trash")
                            }
                            .disabled(bill.services.isEmpty)
                        }

                        Button {
                            coordinator.present(.createBillTemplate(services: bill.services))
                        } label: {
                            Label("Создать шаблон", systemImage: "note.text.badge.plus")
                        }
                        .disabled(bill.services.isEmpty)

                        Menu {
                            ForEach(billTemplates) { template in
                                Button(template.title) {
                                    withAnimation {
                                        bill.services.append(contentsOf: template.services)
                                    }
                                }
                            }
                        } label: {
                            Label("Использовать шаблон", systemImage: "note.text")
                        }
                        .disabled(billTemplates.isEmpty)
                    } label: {
                        Label("Действия", systemImage: "ellipsis.circle")
                    }
                    .disabled(addServices)

                    Spacer()

                    Button {
                        withAnimation {
                            addServices = true
                        }
                    } label: {
                        HStack {
                            Text("Добавить услуги")
                            Image(systemName: "chevron.right")
                        }
                    }
                }
                .padding()
            }
            .background()
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
            .padding([.horizontal, .bottom])

            PriceCalculationView(
                appointment: appointment,
                bill: $bill,
                includeBalance: $includeBalance,
                isCompleted: $isCompleted
            )
            .padding([.horizontal, .bottom])
            .frame(height: 132)
        }
        .navigationTitle("Счет")
        .navigationBarTitleDisplayMode(.inline)
        .sideSheet(isPresented: $addServices) {
            VStack(alignment: .trailing, spacing: 0) {
                SearchBar(text: $searchText)
                PricelistView(filterText: searchText, size: .compact, selectedPricelistItem: .constant(nil))
                    .listStyle(.plain)
            }
        }
        .onAppear {
            loadBasicService()
        }
        .disabled(isCompleted)
    }
}

#Preview {
    NavigationStack {
        BillScreen(appointment: ExampleData.appointment)
            .environmentObject(Coordinator())
    }
    .previewInterfaceOrientation(.landscapeRight)
}

// MARK: - Calculations

private extension BillScreen {
    func loadBasicService() {
        if bill.services.isEmpty, let doctor = appointment.schedule?.doctor, let doctorBasicService = doctor.basicService {
            let predicate = #Predicate<PricelistItem> { $0.id == doctorBasicService.id }
            let descriptor = FetchDescriptor<PricelistItem>(predicate: predicate)
            guard let pricelistItem = try? modelContext.fetch(descriptor).first else { return }
            let service = RenderedService(pricelistItem: pricelistItem, performer: doctor.employee)
            bill.services.append(service)
        }
    }
}
