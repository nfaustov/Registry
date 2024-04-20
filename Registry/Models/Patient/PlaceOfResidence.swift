//
//  PlaceOfResidence.swift
//  Registry
//
//  Created by Николай Фаустов on 20.02.2024.
//

import Foundation

extension Patient {
    struct PlaceOfResidence: Codable, Hashable {
        var region: String
        var locality: String
        var streetAdress: String
        var house: String
        var appartment: String

        init(
            region: String = "",
            locality: String = "",
            streetAdress: String = "",
            house: String = "",
            appartment: String = ""
        ) {
            self.region = region
            self.locality = locality
            self.streetAdress = streetAdress
            self.house = house
            self.appartment = appartment
        }
    }
}
