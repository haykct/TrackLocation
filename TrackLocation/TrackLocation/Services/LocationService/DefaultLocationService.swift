//
//  DefaultLocationService.swift
//  TrackLocation
//
//  Created by Hayk Hayrapetyan on 17.02.24.
//

import CoreLocation

final class DefaultLocationService: NSObject, LocationService {

    // MARK: Public properties

    @Published private(set) var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published private(set) var locationError: Error?

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
            authorizationStatus = .authorized
        case .denied:
            let isLocationServicesEnabled = CLLocationManager.locationServicesEnabled()

            authorizationStatus = isLocationServicesEnabled ? .appLocationDenied : .locationServicesDenied
        case .notDetermined:
            authorizationStatus = .notDetermined
        case .restricted:
            authorizationStatus = .restricted
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
            locationError = clError
        }
    }
}
