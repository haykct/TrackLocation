//
//  MapViewModel.swift
//  TrackLocation
//
//  Created by Hayk Hayrapetyan on 18.02.24.
//

import Combine
import CoreLocation

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
        let currentDistance = (Storage.fetchValue(forKey: UserDefaultsKeys.distance) as? Double) ?? 0

        self.locationService = locationService
        self.viewData = MapViewData(traveledDistanceValue: currentDistance)

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
        Storage.removeValue(forKey: UserDefaultsKeys.distance)
        viewData.resetTraveledDistance()
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
                Storage.storeTemporarily(viewData.traveledDistanceValue)

                previousLocation = currentLocation
            }
            .store(in: &cancellables)
    }
}
