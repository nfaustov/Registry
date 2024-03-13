//
//  ArtmedicsServices.swift
//  Registry
//
//  Created by Николай Фаустов on 13.03.2024.
//

public struct ArtmedicsServices {
    private static var current = ArtmedicsServices()

    static subscript<K: ServiceKey>(key: K.Type) -> K.Value {
        get { key.currentValue }
        set { key.currentValue = newValue }
    }

    static subscript<T>(_ keyPath: WritableKeyPath<ArtmedicsServices, T>) -> T {
        get { current[keyPath: keyPath] }
        set { current[keyPath: keyPath] = newValue }
    }
}

protocol ServiceKey {
    associatedtype Value
    static var currentValue: Value { get set }
}

@propertyWrapper
public struct Service<T> {
    private let keyPath: WritableKeyPath< ArtmedicsServices, T>
    public var wrappedValue: T {
        get { ArtmedicsServices[keyPath] }
        set { ArtmedicsServices[keyPath] = newValue }
    }

    public init(_ keyPath: WritableKeyPath<ArtmedicsServices, T>) {
        self.keyPath = keyPath
    }
}
