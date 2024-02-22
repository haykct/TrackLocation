//
//  Storage.swift
//  TrackLocation
//
//  Created by Hayk Hayrapetyan on 22.02.24.
//

import Foundation

struct Storage {

    // MARK: Private properties

    private static var value: Any?

    // MARK: Initializers

    private init() {}

    // MARK: Public methods

    static func storeTemporarily(_ value: Any) {
        self.value = value
    }

    static func fetchValue(forKey key: String) -> Any? {
        UserDefaults.standard.object(forKey: key)
    }

    static func saveValue(forKey key: String) {
        if let value {
            UserDefaults.standard.setValue(value, forKey: key)
        }
    }

    static func removeValue(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)

        value = nil
    }
}
