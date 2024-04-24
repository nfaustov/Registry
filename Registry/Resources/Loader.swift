//
//  Loader.swift
//  Registry
//
//  Created by Николай Фаустов on 28.02.2024.
//

import Foundation

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

func encode<T: Encodable>(_ value: T) -> Data {
    do {
        return try JSONEncoder().encode(value)
    } catch {
        fatalError("Couldn't encode item of type \(T.self):\n\(error)")
    }
}
