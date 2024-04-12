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

    private let appointment: PatientAppointment
    private let initialBill: Bill

    // MARK: - State

    @State private var bill: Bill
    @State private var isCompleted: Bool = false
    @State private var isPriselistPresented: Bool = false

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
                LabeledContent {
                    if patient.balance != 0 {
                        Text("Баланс: \(Int(patient.balance)) ₽")
                            .foregroundStyle(patient.balance < 0 ? .red : .primary)
                    }
                } label: {
                    Text(patient.fullName)
                        .font(.title3)
                        .padding(.horizontal)
                }
                .padding()
            }

            if let doctor = appointment.schedule?.doctor {
                ServicesTable(doctor: doctor, bill: $bill, editMode: $isPriselistPresented)
                    .servicesTablePurpose(servicesTablePurpose)
                    .background()
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                    .padding([.horizontal, .bottom])
            }

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
                }
                .padding([.horizontal, .bottom])
                .frame(maxHeight: 140)
            } else if servicesTablePurpose == .editRoles {
                Button {
                    editRoles()
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
        .sideSheet(isPresented: $isPriselistPresented) {
            PricelistSideSheetView()
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

// MARK: - Calculations

private extension BillScreen {
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

    func editRoles() {
        if let patient = appointment.patient {
            Task {
                patient.updatePaymentSubject(.bill(bill), forAppointmentID: appointment.id)

                let descriptor = FetchDescriptor<Doctor>()

                if let doctors = try? modelContext.fetch(descriptor) {
                    SalaryCharger.cancelCharge(for: initialBill, doctors: doctors)
                    SalaryCharger.charge(for: .bill(bill), doctors: doctors)
                }
            }

            Task {
                var descriptor = FetchDescriptor<Report>(sortBy: [SortDescriptor(\.date, order: .reverse)])
                descriptor.fetchLimit = 1

                if let report = try? modelContext.fetch(descriptor).first,
                    Calendar.current.isDateInToday(report.date) {
                    report.updatePayment(for: bill)
                }
            }

            dismiss()
        }
    }
}
