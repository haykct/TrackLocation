//
//  DefaultLocationService.swift
//  TrackLocation
//
//  Created by Hayk Hayrapetyan on 17.02.24.
//

import CoreLocation

final class DefaultLocationService: NSObject, LocationService {

    //MARK: Private properties

    private let locationManager: CLLocationManager
    private let shouldMonitorSignificantLocationChanges: Bool

    //MARK: Initializers

    init(locationManager: CLLocationManager, trackLocationAfterAppTermination: Bool = false) {
        self.locationManager = locationManager
        self.shouldMonitorSignificantLocationChanges = trackLocationAfterAppTermination
    }

    //MARK: Public methods

    func requestAuthorization() {
        if shouldMonitorSignificantLocationChanges {
            locationManager.requestAlwaysAuthorization()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func requestLocation() {
        if shouldMonitorSignificantLocationChanges {
            locationManager.startMonitoringSignificantLocationChanges()
        }

        locationManager.startUpdatingLocation()
    }

    //MARK: Private methods

    private func setupLocationManager() {
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.delegate = self
    }
}

extension DefaultLocationService: CLLocationManagerDelegate {

}
