//
//  RegistryApp.swift
//  Registry
//
//  Created by Николай Фаустов on 22.12.2023.
//

import SwiftUI
import SwiftData

typealias DoctorSchedule = RegistrySchemaV3.DoctorSchedule
typealias Doctor = RegistrySchemaV3.Doctor
typealias PatientAppointment = RegistrySchemaV3.PatientAppointment
typealias Patient = RegistrySchemaV3.Patient
typealias Report = RegistrySchemaV3.Report
typealias Payment = RegistrySchemaV3.Payment
typealias CheckTemplate = RegistrySchemaV3.CheckTemplate
typealias PricelistItem = RegistrySchemaV3.PricelistItem
typealias Note = RegistrySchemaV3.Note
typealias Check = RegistrySchemaV3.Check
typealias MedicalService = RegistrySchemaV3.MedicalService
typealias Salary = RegistrySchemaV3.Salary
typealias Refund = RegistrySchemaV3.Refund
typealias Employee = RegistrySchemaV3.Employee
typealias BillTemplate = RegistrySchemaV1.BillTemplate

@main
struct RegistryApp: App {
    @StateObject private var coordinator = Coordinator()
    @StateObject private var scheduleController = ScheduleController()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([DoctorSchedule.self, Report.self, PricelistItem.self, BillTemplate.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(coordinator)
                .environmentObject(scheduleController)
        }
        .modelContainer(sharedModelContainer)
    }
}

enum RegistrySchemaV1: VersionedSchema {
    static var models: [any PersistentModel.Type] {
        [
            DoctorSchedule.self,
            Doctor.self,
            PatientAppointment.self,
            Patient.self,
            Report.self,
            BillTemplate.self,
            PricelistItem.self
        ]
    }

    static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)
}

enum RegistrySchemaV2: VersionedSchema {
    static var models: [any PersistentModel.Type] {
        [
            Payment.self,
            Refund.self,
            MedicalService.self,
            Check.self,
            Note.self,
            DoctorSchedule.self,
            Doctor.self,
            PatientAppointment.self,
            Patient.self,
            Report.self,
            CheckTemplate.self,
            PricelistItem.self,
            BillTemplate.self
        ]
    }

    static var versionIdentifier: Schema.Version = Schema.Version(2, 0, 0)
}

enum RegistrySchemaV3: VersionedSchema {
    static var models: [any PersistentModel.Type] {
        [
            Payment.self,
            Refund.self,
            MedicalService.self,
            Check.self,
            Note.self,
            DoctorSchedule.self,
            Doctor.self,
            PatientAppointment.self,
            Patient.self,
            Report.self,
            CheckTemplate.self,
            PricelistItem.self
        ]
    }

    static var versionIdentifier: Schema.Version = Schema.Version(2, 0, 1)
}

enum RegistryMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [
            RegistrySchemaV1.self,
            RegistrySchemaV2.self,
            RegistrySchemaV3.self
        ]
    }

    static var stages: [MigrationStage] {
        [
            migrationV1toV2,
            migrationV2toV3
        ]
    }
    
    /// Migration to  version 2.0.0
    ///
    /// New models: `MedicalService`, `Note`, `Check`, `Refund`, `Payment`
    ///
    /// Removed models: `BillTemplate`
    ///
    /// `Doctor` model changes:
    /// - added **defaultPricelistItem** property relationship with `PricelistItem`
    /// - added new property **doctorSalary** with new version of type `Salary`
    /// - added properties **performedServices** and **appointedServices** relationship with `MedicalService`
    ///
    /// `DoctorSchedule` model changes:
    /// - added **note** property relationship with `Note`
    ///
    /// `PatientAppointment` model changes:
    /// - added properties **registrationDate** and **registrar**
    /// - added **note** property relationship with `Note`
    /// - added **check** property relationship with `Check`
    ///
    /// `PricelistItem` model changes:
    /// - added **fixedAgentFee** property,
    /// - renamed property **salaryAmount** to **fixedSalary**
    /// - added **medicalServices** property relationship with `MedicalService`
    ///
    private static let migrationV1toV2 = MigrationStage.custom(
        fromVersion: RegistrySchemaV1.self,
        toVersion: RegistrySchemaV2.self,
        willMigrate: { context in
            let schedulesDescriptor = FetchDescriptor<RegistrySchemaV1.DoctorSchedule>()
            let schedules = try context.fetch(schedulesDescriptor)

            for schedule in schedules {
                context.delete(schedule)
            }

            let reportsDescriptor = FetchDescriptor<RegistrySchemaV1.Report>()
            let reports = try context.fetch(reportsDescriptor)

            for report in reports {
                context.delete(report)
            }

            let billTemplatesDescriptor = FetchDescriptor<RegistrySchemaV1.BillTemplate>()
            let billTempaltes = try context.fetch(billTemplatesDescriptor)

            for billTempalte in billTempaltes {
                context.delete(billTempalte)
            }

            try context.save()
        },
        didMigrate: { context in
            let doctorDescriptor = FetchDescriptor<RegistrySchemaV2.Doctor>()
            let doctors = try context.fetch(doctorDescriptor)

            try doctors.forEach { doctor in
                if let doctorID = doctor.basicService?.id {
                    let pricelistItemPredicate = #Predicate<RegistrySchemaV2.PricelistItem> { $0.id == doctorID }
                    var pricelistItemDescriptor = FetchDescriptor(predicate: pricelistItemPredicate)
                    pricelistItemDescriptor.fetchLimit = 1

                    if let pricelistItem = try context.fetch(pricelistItemDescriptor).first {
                        doctor.defaultPricelistItem = pricelistItem
                    }
                }
                
                switch doctor.salary {
                case .pieceRate(let rate):
                    doctor.doctorSalary = .pieceRate(rate: rate)
                case .monthly(let amount):
                    doctor.doctorSalary = .monthly(amount: amount)
                case .hourly(let amount):
                    doctor.doctorSalary = .hourly(amount: amount)
                }
            }

            let patientsDescriptor = FetchDescriptor<RegistrySchemaV2.Patient>()
            let patients = try context.fetch(patientsDescriptor)

            patients.forEach { patient in
                patient.visits.removeAll()
            }

            let pricelistItemDescriptor = FetchDescriptor<RegistrySchemaV2.PricelistItem>()
            let items = try context.fetch(pricelistItemDescriptor)

            for item in items {
                item.fixedSalary = item.salaryAmount
                item.fixedAgentFee = nil
            }

            let report = RegistrySchemaV2.Report(date: .now, startingCash: 1062)
            context.insert(report)

            try context.save()
        }
    )

    
    /// Migration to version 2.0.1
    /// - Removed **salary** and **basicService**  properties in `Doctor`
    /// - Removed `Visit` struct, removed **visits** property in `Patient`
    /// - Removed **visitID** property in `PatientAppointment`
    /// - Removed `Bill`, `RenderedService`, `Refund` structs
    private static let migrationV2toV3 = MigrationStage.lightweight(
        fromVersion: RegistrySchemaV2.self,
        toVersion: RegistrySchemaV3.self
    )
}
