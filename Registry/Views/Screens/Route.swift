//
//  Route.swift
//  Registry
//
//  Created by Николай Фаустов on 22.12.2023.
//

import SwiftUI

enum Route: Hashable {
    case appointments
    case bill//(appointment: PatientAppointment, doctor: Doctor)
    case doctorDetail//(doctor: Doctor)
    case patientCard//(patientModel: Patient.DBModel)
}
