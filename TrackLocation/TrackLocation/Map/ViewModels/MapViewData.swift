//
//  MapViewData.swift
//  TrackLocation
//
//  Created by Hayk Hayrapetyan on 22.02.24.
//

import CoreLocation

struct MapViewData {

    // MARK: Public properties

    private(set) var traveledDistance: String = ""

    // MARK: Private properties

    private var previousLocation: CLLocation?
    private var traveledDistanceValue: Double {
        didSet {
            setupTraveledDistance()
        }
    }

    // MARK: Initializers

    init(traveledDistanceValue: Double) {
        self.traveledDistanceValue = traveledDistanceValue
    }

    // MARK: Public methods

    mutating func update(_ currentLocation: CLLocation) {
        if let previousLocation {
            traveledDistanceValue += previousLocation.distance(from: currentLocation)
            Storage.storeTemporarily(traveledDistanceValue)
        }

        previousLocation = currentLocation
    }

    mutating func resetTraveledDistance() {
        traveledDistanceValue = 0
    }

    mutating func resetPreviousLocation() {
        previousLocation = nil
    }

    // MARK: Private methods

    private mutating func setupTraveledDistance() {
        let roundedValue = Int(traveledDistanceValue.rounded())

        if roundedValue < 1000 {
            traveledDistance = "\(roundedValue)m"

            return
        }

        let kilometerValue: Double = Double(roundedValue) / 1000
        let digitCountAfterDecimalPoint = String(kilometerValue).components(separatedBy: ".").last?.count ?? 0

        if digitCountAfterDecimalPoint <= 2 {
            traveledDistance = "\(kilometerValue)km"
        } else {
            traveledDistance = String(format: "%.2f", kilometerValue) + "km"
        }
    }
}
