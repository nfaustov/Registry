//
//  Route.swift
//  Registry
//
//  Created by Николай Фаустов on 22.12.2023.
//

import SwiftUI

enum Route: Hashable {
    case appointments
    case bill(for: PatientAppointment)
    case doctorDetail(Doctor)
    case patientCard(Patient)
}
