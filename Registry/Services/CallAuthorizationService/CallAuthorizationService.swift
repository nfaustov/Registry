//
//  CallAuthorizationService.swift
//  Registry
//
//  Created by Николай Фаустов on 26.03.2024.
//

import Foundation

public protocol CallAuthorizationService {
    func call(phoneNumber: String) async throws -> CallAuthorizationEntity
}
