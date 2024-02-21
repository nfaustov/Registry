//
//  PlaceOfResidence.swift
//  Registry
//
//  Created by Николай Фаустов on 20.02.2024.
//

import Foundation

public extension Patient {
    struct PlaceOfResidence: Codable, Hashable {
        public let region: String
        public let locality: String
        public let streetAdress: String
        public let house: String
        public let appartment: String

        public init(
            region: String,
            locality: String,
            streetAdress: String,
            house: String,
            appartment: String
        ) {
            self.region = region
            self.locality = locality
            self.streetAdress = streetAdress
            self.house = house
            self.appartment = appartment
        }
    }
}
