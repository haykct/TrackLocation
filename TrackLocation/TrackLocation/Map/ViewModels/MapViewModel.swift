//
//  MapViewModel.swift
//  TrackLocation
//
//  Created by Hayk Hayrapetyan on 18.02.24.
//

import Combine
import CoreLocation
import Foundation

struct MapViewData {
    var traveledDistance: Double

    mutating func update(previousLocation: CLLocation?, currentLocation: CLLocation) {
        if let previousLocation {
            traveledDistance += previousLocation.distance(from: currentLocation)
        }
    }
}

struct Storage {
    private static var value: Any?

    private init() {}

    static func storeTemporarily(_ value: Any) {
        self.value = value
    }

    static func fetch(forKey key: String) -> Any? {
        UserDefaults.standard.object(forKey: key)
    }

    static func save(forKey key: String) {
        if let value {
            UserDefaults.standard.setValue(value, forKey: key)
        }
    }

    static func remove(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)

        value = nil
    }
}

final class MapViewModel {
    // MARK: Public properties

    @Published private(set) var authorizationStatus: AuthorizationStatus?
    @Published private(set) var serviceError: LocationError?
    @Published private(set) var viewData: MapViewData

    // MARK: Private properties

    private var locationService: LocationService
    private var previousLocation: CLLocation?
    private var cancellables = Set<AnyCancellable>()

    // MARK: Initializers

    init(locationService: LocationService) {
        let currentdDistance = (Storage.fetch(forKey: UserDefaultsKeys.distance) as? Double) ?? 0

        self.locationService = locationService
        self.viewData = MapViewData(traveledDistance: currentdDistance)

        subscribeToLocationServiceChanges()
    }

    // MARK: Public methods

    func startUpdatingLocation() {
        locationService.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationService.stopUpdatingLocation()
    }

    func resetPreviousLocation() {
        previousLocation = nil
    }

    func resetDistance() {
        Storage.remove(forKey: UserDefaultsKeys.distance)
        viewData.traveledDistance = 0
    }

    // MARK: Private methods

    private func subscribeToLocationServiceChanges() {
        locationService.authorizationStatus
            .sink(receiveValue: { [weak self] status in
                self?.authorizationStatus = status
            })
            .store(in: &cancellables)

        locationService.locationError
            .sink { [weak self] _ in
                self?.serviceError = .error
            }
            .store(in: &cancellables)

        locationService.location
            .sink { [weak self] currentLocation in
                guard let self else { return }

                viewData.update(previousLocation: previousLocation, currentLocation: currentLocation)
                Storage.storeTemporarily(viewData.traveledDistance)
                
                previousLocation = currentLocation
            }
            .store(in: &cancellables)
    }
}
