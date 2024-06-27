//
//  ExampleData.swift
//  Registry
//
//  Created by Николай Фаустов on 06.01.2024.
//

import Foundation

struct ExampleData {
    static var doctor = Doctor(
        secondName: "Сегеда",
        firstName: "Светлана",
        patronymicName: "Ивановна",
        phoneNumber: "+7 (999) 999-99-99",
        birthDate: Date(),
        department: .gynecology,
        defaultPricelistItem: pricelistItem,
        serviceDuration: 1800,
        defaultCabinet: 2,
        doctorSalary: .monthly(amount: 39000),
        image: Data(),
        accessLevel: .registrar
    )

    static var patient = Patient(secondName: "Ivanov", firstName: "Ivan", patronymicName: "Ivanovich", phoneNumber: "+7 (999) 999-99-99")
    static var patient2 = Patient(secondName: "Petrov", firstName: "Petr", patronymicName: "Petrovich", phoneNumber: "+7 (900) 900-90-90")
    static var patient3 = Patient(secondName: "Fedorov", firstName: "Fedor", patronymicName: "Fedorovich", phoneNumber: "+7 (920) 920-92-92")

    static var check = Check(services: [])
    static var appointment = PatientAppointment(scheduledTime: Date(), duration: 1800, patient: patient, status: .completed, check: check)

    static var doctorSchedule = DoctorSchedule(
        doctor: doctor,
        cabinet: 2, 
        starting: Date(),
        ending: Date().addingTimeInterval(10_800),
        patientAppointments: [
            PatientAppointment(scheduledTime: Date(), duration: 1800, patient: patient),
            PatientAppointment(scheduledTime: Date().addingTimeInterval(1800), duration: 1800, patient: patient2),
            PatientAppointment(scheduledTime: Date().addingTimeInterval(3600), duration: 1800, patient: nil),
            PatientAppointment(scheduledTime: Date().addingTimeInterval(5400), duration: 1800, patient: nil),
            PatientAppointment(scheduledTime: Date().addingTimeInterval(7200), duration: 1800, patient: patient3),
            PatientAppointment(scheduledTime: Date().addingTimeInterval(9000), duration: 1800, patient: nil)
        ]
    )

    static let payment1 = Payment(purpose: .medicalServices, details: "Фаустов Н.И.", methods: [.init(.card, value: 1200)], createdBy: doctor.asAnyUser)
    static let payment2 = Payment(purpose: .medicalServices, details: "Башкова М.Б.", methods: [.init(.cash, value: 2420)], createdBy: doctor.asAnyUser)
    static let payment3 = Payment(purpose: .consumables, details: "Аптека", methods: [.init(.cash, value: -1000)], createdBy: doctor.asAnyUser)

    static let report = Report(date: .now, startingCash: 100, payments: [payment1, payment2, payment3])

    static let pricelistItem = PricelistItem(id: "А04.10.002", category: .ultrasound, title: "Эхокардиография (УЗИ сердца с допплерографией)", price: 1100)
    static let service = MedicalService(pricelistItem: pricelistItem.snapshot, performer: doctor)
}
