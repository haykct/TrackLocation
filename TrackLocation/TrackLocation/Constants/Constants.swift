//
//  Constants.swift
//  TrackLocation
//
//  Created by Hayk Hayrapetyan on 19.02.24.
//

import UIKit

enum Coordinates {
    static let initialLatitude = 14.6349
    static let initialLongitude = -90.5069
}

enum UserDefaultsKeys {
    static let shouldTrack = "shouldTrack"
    static let distance = "distance"
}

enum StoryboardIDs {
    static let map = "Map"
}

enum Colors {
    static let mapBlue = UIColor(named: "mapBlue") ?? .clear
}
