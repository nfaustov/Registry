//
//  ScheduleController.swift
//  Registry
//
//  Created by Николай Фаустов on 26.02.2024.
//

import Foundation

final class ScheduleController: ObservableObject {
    @Published var selectedSchedule: DoctorSchedule? = nil
    @Published var date: Date = .now
}
