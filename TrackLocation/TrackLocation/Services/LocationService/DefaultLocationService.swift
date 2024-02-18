//
//  DefaultLocationService.swift
//  TrackLocation
//
//  Created by Hayk Hayrapetyan on 17.02.24.
//

import CoreLocation

final class DefaultLocationService: NSObject, LocationService {

    // MARK: Public properties
    // Keeping as a subject since property wrappers(@Published) aren't allowed in protocols.
    private(set) var authorizationStatus = LocationService.StatusSubject()
    private(set) var locationError = LocationService.LocationErrorSubject()

    // MARK: Private properties

    private let locationManager: CLLocationManager

    // MARK: Initializers

    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
    }

    // MARK: Public methods

    func startUpdatingLocation() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }

        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
    }

    // MARK: Private methods

    private func setupLocationManager() {
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.delegate = self
    }

    private func getAuthorizationStatus() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            authorizationStatus.send(.authorized)
        case .denied:
            let isLocationServicesEnabled = CLLocationManager.locationServicesEnabled()

            authorizationStatus.send(isLocationServicesEnabled ? .appLocationDenied : .locationServicesDenied)
        case .notDetermined:
            authorizationStatus.send(.notDetermined)
        case .restricted:
            authorizationStatus.send(.restricted)
        default:
            break
        }
    }
}

// MARK: CLLocationManagerDelegate

extension DefaultLocationService: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    }

    func locationManagerDidChangeAuthorization(_: CLLocationManager) {
        getAuthorizationStatus()
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError, clError.code != .denied {
            locationError.send(clError)
        }
    }
}
