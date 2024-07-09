//
//  RegistryTests.swift
//  RegistryTests
//
//  Created by Николай Фаустов on 09.05.2024.
//

import XCTest
import SwiftData
import Algorithms

final class RegistryTests: XCTestCase {
    
    private var context: ModelContext!
    private var ledger: Ledger!
    
    private var doctor: Doctor!
    private var doctorSchedule: DoctorSchedule!
    private var patient: Patient!
    private var medicalService: MedicalService!

    @MainActor 
    override func setUp() {
        context = mockContainer.mainContext

        doctor = Doctor(
            secondName: "Петров",
            firstName: "Петр",
            patronymicName: "Петрович",
            phoneNumber: "+7 (999) 999-99-99",
            birthDate: Date(),
            department: Department.gynecology,
            serviceDuration: 600,
            defaultCabinet: 1,
            doctorSalary: Salary.pieceRate(rate: 0.4, minAmount: 1000)
        )

        patient = Patient(
            secondName: "Ivanov",
            firstName: "Ivan",
            patronymicName: "Ivanovich",
            phoneNumber: "+7 (999) 999-99-99"
        )

        doctorSchedule = DoctorSchedule(
            doctor: doctor,
            cabinet: 1,
            starting: .now,
            ending: .now.addingTimeInterval(3600)
        )

        context.insert(doctorSchedule)

        guard let appointment = doctorSchedule.patientAppointments?.first else { return }

        appointment.registerPatient(patient, duration: 600, registrar: SuperUser.boss.asAnyUser)

        guard let check = appointment.check else { return }

        let pricelistItem = PricelistItem(
            id: "100",
            category: .cardiology,
            title: "Прием кардиолога",
            price: 1500
        )
        medicalService = MedicalService(pricelistItem: pricelistItem.snapshot, performer: doctor, agent: doctor)

        check.services.append(medicalService)

        ledger = Ledger(modelContext: context)
    }

    override func tearDownWithError() throws {
        try context.delete(model: DoctorSchedule.self)
        try context.delete(model: Doctor.self)
        try context.delete(model: Patient.self)
        try context.delete(model: Report.self)
    }

    @MainActor func testMedicalServicePayment() throws {
        guard let appointment = doctorSchedule.patientAppointments?.first,
              let check = appointment.check else { return }

        let method = Payment.Method(.cash, value: 1550)

        try ledger.makePayment(.medicalService(patient: patient, check: check, methods: [method]), createdBy: SuperUser.boss)
        let report = ledger.getReport()

        XCTAssertEqual(appointment.status, .completed)
        XCTAssertEqual(patient.balance, 50)
        XCTAssertEqual(patient.transactions?.count, 2)
        XCTAssertEqual(doctor.balance, 750)
        XCTAssertEqual(report?.payments?.count, 1)
        XCTAssertEqual(report?.cashBalance, 1550)
    }

    @MainActor
    func testMedicalServicePayment2() throws {
        guard let appointment = doctorSchedule.patientAppointments?.first,
              let check = appointment.check else { return }

        let method1 = Payment.Method(.bank, value: 1400)
        let method2 = Payment.Method(.cash, value: 300)

        try ledger.makePayment(.medicalService(patient: patient, check: check, methods: [method1, method2]), createdBy: SuperUser.boss)
        let report = ledger.getReport()

        XCTAssertEqual(appointment.status, .completed)
        XCTAssertEqual(patient.balance, 200)
        XCTAssertEqual(patient.transactions?.count, 2)
        XCTAssertEqual(doctor.balance, 750)
        XCTAssertEqual(report?.payments?.count, 1)
        XCTAssertEqual(report?.cashBalance, 300)
        XCTAssertEqual(report?.reporting(.income, of: .bank), 1400)
    }

    @MainActor
    func testDoctorPayoutPayment() throws {
        doctor.updateBalance(increment: 1200)

        let method = Payment.Method(.cash, value: -800)

        try ledger.makePayment(.doctorPayout(doctor, methods: [method]), createdBy: SuperUser.boss)
        let report = ledger.getReport()

        XCTAssertEqual(doctor.transactions?.count, 1)
        XCTAssertEqual(doctor.balance, 400)
        XCTAssertEqual(report?.payments?.count, 1)
        XCTAssertEqual(report?.cashBalance, -800)
    }

    @MainActor
    func testDoctorPayoutPayment2() throws {
        doctor.updateBalance(increment: 1200)

        let method1 = Payment.Method(.cash, value: -800)
        let method2 = Payment.Method(.card, value: -400)

        try ledger.makePayment(.doctorPayout(doctor, methods: [method1, method2]), createdBy: SuperUser.boss)
        let report = ledger.getReport()

        XCTAssertEqual(doctor.transactions?.count, 1)
        XCTAssertEqual(doctor.balance, 0)
        XCTAssertEqual(report?.payments?.count, 1)
        XCTAssertEqual(report?.cashBalance, -800)
        XCTAssertEqual(report?.reporting(.expense, of: .card), -400)
    }

    @MainActor
    func testRefundPayment() throws {
        guard let appointment = doctorSchedule.patientAppointments?.first,
              let check = appointment.check else { return }

        let paymentMethod = Payment.Method(.bank, value: 1300)

        try ledger.makePayment(.medicalService(patient: patient, check: check, methods: [paymentMethod]), createdBy: SuperUser.boss)

        let refund = Refund(services: [medicalService])
        check.makeRefund(refund)
        try ledger.makePayment(.refund(refund, paymentType: .cash, includeBalance: false), createdBy: SuperUser.boss)
        let report = ledger.getReport()

        XCTAssertEqual(doctor.balance, 0)
        XCTAssertEqual(patient.balance, -200)
        XCTAssertEqual(report?.payments?.count, 2)
        XCTAssertEqual(report?.cashBalance, -1300)
        XCTAssertEqual(report?.reporting(.income, of: .bank), 1300)
    }

    @MainActor
    func testRefundPayment2() throws {
        guard let appointment = doctorSchedule.patientAppointments?.first,
              let check = appointment.check else { return }

        let paymentMethod = Payment.Method(.bank, value: 1300)

        try ledger.makePayment(.medicalService(patient: patient, check: check, methods: [paymentMethod]), createdBy: SuperUser.boss)

        let refund = Refund(services: [medicalService])
        check.makeRefund(refund)
        try ledger.makePayment(.refund(refund, paymentType: .cash, includeBalance: true), createdBy: SuperUser.boss)
        let report = ledger.getReport()

        XCTAssertEqual(doctor.balance, 0)
        XCTAssertEqual(patient.balance, 0)
        XCTAssertEqual(report?.payments?.count, 2)
        XCTAssertEqual(report?.cashBalance, -1300)
        XCTAssertEqual(report?.reporting(.income, of: .bank), 1300)
    }

    @MainActor
    func testBalancePayment() throws {
        try ledger.makePayment(.balance(.payout, person: patient, method: .init(.cash, value: 200)), createdBy: SuperUser.boss)
        let report = ledger.getReport()

        XCTAssertEqual(report?.payments?.count, 1)
        XCTAssertEqual(report?.cashBalance, -200)
        XCTAssertEqual(patient.balance, -200)
        XCTAssertEqual(patient.transactions?.count, 1)
    }

    @MainActor
    func testSpendingPayment() throws {
        try ledger.makePayment(.spending(purpose: .building, details: "", method: .init(.cash, value: 450)), createdBy: SuperUser.boss)
        let report = ledger.getReport()

        XCTAssertEqual(report?.payments?.count, 1)
        XCTAssertEqual(report?.cashBalance, -450)
    }
}
