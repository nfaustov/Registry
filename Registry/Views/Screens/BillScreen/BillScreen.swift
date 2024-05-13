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

    // MARK: - State

    @State private var check: Check
    @State private var isCompleted: Bool = false
    @State private var isPriselistPresented: Bool = false

    // MARK: -

    init(appointment: PatientAppointment) {
        self.appointment = appointment

        if let check = appointment.check {
            _check = State(initialValue: check)
        } else {
            _check = State(initialValue: Check())
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
                ServicesTable(doctor: doctor, check: check, editMode: $isPriselistPresented)
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
                        check: check,
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
            }
        }
        .navigationTitle("Счет")
        .navigationBarTitleDisplayMode(.inline)
        .sideSheet(isPresented: $isPriselistPresented) {
            PricelistSideSheetView()
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    NavigationStack {
        BillScreen(appointment: ExampleData.appointment)
            .environmentObject(Coordinator())
    }
    .previewInterfaceOrientation(.landscapeRight)
}
