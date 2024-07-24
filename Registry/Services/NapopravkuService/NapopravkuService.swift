//
//  NapopravkuService.swift
//  Registry
//
//  Created by Николай Фаустов on 24.07.2024.
//

import Foundation

protocol NapopravkuService {
    func getAppointmentList() async throws -> AppointmentsListEntity
    func setReceivedAppointment() async throws
}
