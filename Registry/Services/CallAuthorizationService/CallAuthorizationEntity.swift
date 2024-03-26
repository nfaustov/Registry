//
//  CallAuthorizationEntity.swift
//  Registry
//
//  Created by Николай Фаустов on 26.03.2024.
//

import Foundation

public struct CallAuthorizationEntity: Decodable {
    enum CodingKeys: String, CodingKey {
        case statusText = "status_text"
        case code
    }

    var statusText: String?
    var code: String?
}
