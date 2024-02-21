//
//  LocationService.swift
//  TrackLocation
//
//  Created by Hayk Hayrapetyan on 18.02.24.
//

import Combine
import CoreLocation

enum AuthorizationStatus {
    case authorized
    case appLocationDenied
    case locationServicesDenied
    case notDetermined
    case restricted
}

enum LocationError: Error {
    case error
}

protocol LocationService {
    typealias LocationErrorSubject = PassthroughSubject<Error, Never>
    typealias StatusSubject = PassthroughSubject<AuthorizationStatus, Never>
    typealias LocationSubject = PassthroughSubject<CLLocation, Never>

    var authorizationStatus: StatusSubject { get }
    var locationError: LocationErrorSubject { get }
    var location: LocationSubject { get }

    func startUpdatingLocation()
    func stopUpdatingLocation()
}
