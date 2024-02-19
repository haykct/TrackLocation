//
//  Persisted.swift
//  TrackLocation
//
//  Created by Hayk Hayrapetyan on 19.02.24.
//

import Foundation

@propertyWrapper struct Persisted<T> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }

        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
