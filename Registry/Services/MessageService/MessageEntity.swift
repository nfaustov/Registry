//
//  MessageEntity.swift
//  Registry
//
//  Created by Николай Фаустов on 13.03.2024.
//

import Foundation

public struct MessageEntity: Decodable {
    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case balance, sms
    }

    let statusCode: Int
    let sms: [String: SMSEntity]
    let balance: Double
}

public struct SMSEntity: Decodable {
    enum CodingKeys: String, CodingKey {
        case status
        case statusText = "status_text"
    }

    let status: String
    let statusText: String?
}
