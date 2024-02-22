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
    @Published private(set) var mapViewData: MapViewData

    // MARK: Private properties

    private var locationService: LocationService
    // View data which calculates and stores the final representation of the data.
    private var viewData: MapViewData
    private var cancellables = Set<AnyCancellable>()

    // MARK: Initializers

    init(locationService: LocationService) {
        let currentDistance = (Storage.fetchValue(forKey: UserDefaultsKeys.distance) as? Double) ?? 0

        self.locationService = locationService
        self.viewData = MapViewData(traveledDistanceValue: currentDistance)
        self.mapViewData = viewData

        subscribeToLocationServiceUpdates()
    }

    // MARK: Public methods

    func startUpdatingLocation() {
        locationService.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationService.stopUpdatingLocation()
        viewData.resetPreviousLocation()
    }

    // Resets the distance traveled value and updates the view, when the user presses the stop tracking button.
    func resetDistance() {
        Storage.removeValue(forKey: UserDefaultsKeys.distance)
        viewData.resetTraveledDistance()
        mapViewData = viewData
    }

    // MARK: Private methods

    private func subscribeToLocationServiceUpdates() {
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

                viewData.update(currentLocation)
                mapViewData = viewData
            }
            .store(in: &cancellables)
    }
}
