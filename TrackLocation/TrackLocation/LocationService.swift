//
//  LocationService.swift
//  TrackLocation
//
//  Created by Hayk Hayrapetyan on 18.02.24.
//

enum AuthorizationStatus {
    case authorized
    case appLocationDenied
    case locationServicesDenied
    case notDetermined
    case restricted
}

protocol LocationService {
    var authorizationStatus: AuthorizationStatus { get }

    func startUpdatingLocation()
}
