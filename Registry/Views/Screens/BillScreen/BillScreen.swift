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
    @Environment(\.dismiss) private var dismiss
    @Environment(\.servicesTablePurpose) private var servicesTablePurpose

    @EnvironmentObject private var coordinator: Coordinator

    @Query private var billTemplates: [BillTemplate]
    @Query(sort: \Report.date, order: .reverse) private var reports: [Report]

    private let appointment: PatientAppointment
    private let initialBill: Bill

    // MARK: - State

    @State private var bill: Bill
    @State private var addServices: Bool = false
    @State private var isCompleted = false
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    @State private var selectedTemplate: BillTemplate?

    // MARK: -

    init(appointment: PatientAppointment) {
        self.appointment = appointment

        if let visit = appointment.patient?.visit(forAppointmentID: appointment.id),
           let bill = visit.bill {
            _bill = State(initialValue: bill)
            initialBill = bill
        } else {
            _bill = State(initialValue: Bill(services: []))
            initialBill = Bill(services: [])
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
                        Text("Баланс: \(Int(patient.balance)) ₽")
                            .foregroundStyle(patient.balance < 0 ? .red : .primary)
                    }
                }
                .padding()
            }

            VStack(spacing: 0) {
                if let doctor = appointment.schedule?.doctor {
                    ServicesTable(bill: $bill, doctor: doctor, editMode: addServices)
                        .servicesTablePurpose(servicesTablePurpose)
                        .onChange(of: bill.services) { _, newValue in
                            if !newValue.contains(selectedTemplate?.services ?? []) {
                                selectedTemplate = nil
                            }
                        }
                }

                if servicesTablePurpose == .createAndPay {
                    controls
                }
            }
            .background()
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
            .padding([.horizontal, .bottom])

            if servicesTablePurpose == .createAndPay {
                HStack(alignment: .bottom) {
                    PriceCalculationView(
                        appointment: appointment,
                        bill: $bill,
                        isCompleted: $isCompleted
                    )
                    .onChange(of: isCompleted) { _, newValue in
                        if newValue {
                            dismiss()
                        }
                    }

                    if let selectedTemplate {
                        Spacer()
                        Menu {
                            Button("Удалить", role: .destructive) {
                                withAnimation {
                                    modelContext.delete(selectedTemplate)
                                    self.selectedTemplate = nil
                                }
                            }
                        } label: {
                            VStack(alignment: .leading) {
                                Text("Шаблон")
                                    .font(.headline)
                                Text("\(selectedTemplate.title)")
                                    .font(.subheadline)
                            }
                            .padding(12)
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                    }
                }
                .padding([.horizontal, .bottom])
                .frame(maxHeight: 140)
            } else if servicesTablePurpose == .editRoles {
                Button {
                    if let patient = appointment.patient {
                        patient.updatePaymentSubject(.bill(bill), forAppointmentID: appointment.id)
                        let descriptor = FetchDescriptor<Doctor>()

                        if let doctors = try? modelContext.fetch(descriptor) {
                            SalaryCharger.cancelCharge(for: initialBill, doctors: doctors)
                            SalaryCharger.charge(for: .bill(bill), doctors: doctors)
                        }
                        
                        todayReport?.updatePayment(for: bill)
                    }

                    dismiss()
                } label: {
                    Text("Готово")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 28)
                }
                .buttonStyle(.borderedProminent)
                .padding([.horizontal, .bottom])
            }
        }
        .navigationTitle("Счет")
        .navigationBarTitleDisplayMode(.inline)
        .sideSheet(isPresented: $addServices) {
            VStack(alignment: .trailing, spacing: 0) {
                SearchBar(text: $searchText, isPresented: $isSearching)
                PricelistView(filterText: searchText, size: .compact, isSearching: $isSearching)
                    .listStyle(.plain)
            }
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            if servicesTablePurpose == .createAndPay {
                loadBasicService()
            }
        }
    }
}

#Preview {
    NavigationStack {
        BillScreen(appointment: ExampleData.appointment)
            .environmentObject(Coordinator())
    }
    .previewInterfaceOrientation(.landscapeRight)
}

// MARK: - Subviews

private extension BillScreen {
    var controls: some View {
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
                                selectedTemplate = template
                                bill.services.append(contentsOf: template.services)
                                bill.discount += template.discount
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
            .disabled(addServices || (bill.services.isEmpty && billTemplates.isEmpty))

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
}

// MARK: - Calculations

private extension BillScreen {
    var todayReport: Report? {
        if let report = reports.first, Calendar.current.isDateInToday(report.date) {
            return report
        } else {
            return nil
        }
    }

    func loadBasicService() {
        if bill.services.isEmpty, let patient = appointment.patient {
            patient.mergedAppointments(forAppointmentID: appointment.id).forEach { visitAppointment in
                if let doctor = visitAppointment.schedule?.doctor, 
                    let pricelistItem = doctor.basicService {
                    let service = RenderedService(pricelistItem: pricelistItem, performer: doctor.employee)
                    bill.services.append(service)
                    patient.updatePaymentSubject(.bill(bill), forAppointmentID: appointment.id)
                }
            }
        }
    }
}
