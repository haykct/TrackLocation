//
//  MapViewModel.swift
//  TrackLocation
//
//  Created by Hayk Hayrapetyan on 18.02.24.
//

import Combine

final class MapViewModel {
    // MARK: Public properties

    @Published private(set) var authorizationStatus: AuthorizationStatus?
    @Published private(set) var serviceError: LocationError?

    // MARK: Private properties

    private var locationService: LocationService
    private var cancellables = Set<AnyCancellable>()

    // MARK: Initializers

    init(locationService: LocationService) {
        self.locationService = locationService

        subscribeToLocationServiceChanges()
    }

    // MARK: Public methods

    func startUpdatingLocation() {
        locationService.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationService.stopUpdatingLocation()
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
    }
}
