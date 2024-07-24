//
//  AppointmentsListEntity.swift
//  Registry
//
//  Created by Николай Фаустов on 24.07.2024.
//

import Foundation

public struct AppointmentsListEntity: Decodable {
    let items: AppointmentEntity
}

public struct AppointmentEntity: Decodable {
    enum CodingKeys: String, CodingKey {
        case uuid, doctor, comment
        case serviceID = "mis_service_id"
        case startTime = "start_time"
        case endTime = "end_time"
        case patientSurname = "patient_surname"
        case patientFirstname = "patient_firstname"
        case patientFathername = "patient_father_name"
        case patientGender = "patient_gender"
        case patientPhone = "patient_phone"
        case patientBirthday = "patient_birthday"
        case createdAt = "created_at"
    }

    let uuid: String
    let doctor: DoctorEntity
    let serviceID: String?
    let startTime: Date
    let endTime: Date
    let patientSurname: String?
    let patientFirstname: String?
    let patientFathername: String?
    let patientGender: GenderEntity?
    let patientPhone: String?
    let patientBirthday: Date?
    let comment: String?
    let createdAt: Date
}

public struct DoctorEntity: Decodable {
    enum CodingKeys: String, CodingKey {
        case doctorID = "mis_doctor_id"
        case name
    }

    let doctorID: String
    let name: String
}

public enum GenderEntity: String, Decodable {
    case male
    case female
}
