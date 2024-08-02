//
//  RegistrarActivity.swift
//  Registry
//
//  Created by Николай Фаустов on 02.07.2024.
//

import Foundation

struct RegistrarActivity: Hashable {
    let registrar: Doctor
    var activity: Int
}

struct RegistrarAppointments: Hashable {
    let registrar: Doctor
    var appointments: [PatientAppointment]
}
