//
//  DefaultLocationService.swift
//  TrackLocation
//
//  Created by Hayk Hayrapetyan on 17.02.24.
//

import CoreLocation

final class DefaultLocationService: NSObject, LocationService {

    // MARK: Public properties
    private static let allowedTimestampInterval: Double = 2

    // Keeping as a subject since property wrappers(@Published) aren't allowed in protocols.
    private(set) var authorizationStatus = LocationService.StatusSubject()
    private(set) var locationError = LocationService.LocationErrorSubject()
    private(set) var location = LocationService.LocationSubject()

    // MARK: Private properties

    private let locationManager: CLLocationManager

    // MARK: Initializers

    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager

        super.init()
        setupLocationManager()
    }

    // MARK: Public methods

    func startUpdatingLocation() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }

        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopUpdatingLocation()
    }

    // MARK: Private methods

    private func setupLocationManager() {
        // You can also use kCLLocationAccuracyBestForNavigation but it may consume the battery power faster.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
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
            DispatchQueue.global().async {
                // In case of calling this methods on the main thread compiler warns about UI unresponsiveness.
                // We can move it to a background thread.
                let isLocationServicesEnabled = CLLocationManager.locationServicesEnabled()

                DispatchQueue.main.async {
                    self.authorizationStatus.send(isLocationServicesEnabled
                                                  ? .appLocationDenied
                                                  : .locationServicesDenied)
                }
            }
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
        if let lastLocation = locations.last,
            abs(lastLocation.timestamp.timeIntervalSinceNow) <= DefaultLocationService.allowedTimestampInterval {
            location.send(lastLocation)
        }
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
