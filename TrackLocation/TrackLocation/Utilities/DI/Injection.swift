//
//  Injection.swift
//  TrackLocation
//
//  Created by Hayk Hayrapetyan on 18.02.24.
//

import CoreLocation
import Swinject

class Injection {
    // MARK: Public properties

    static let shared = Injection()

    lazy var container = Container { container in
        register(using: container)
    }

    // MARK: Initializers

    private init() {}
}

extension Injection {
    // I used Swinject to register dependencies so I could use them
    // in different classes by injecting them externally.
    private func register(using container: Container) {
        container.register(LocationService.self) { _ in
            DefaultLocationService(locationManager: CLLocationManager())
        }
    }
}
