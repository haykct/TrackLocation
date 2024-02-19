//
//  ViewController.swift
//  TrackLocation
//
//  Created by Hayk Hayrapetyan on 17.02.24.
//

import UIKit
import MapKit
import Combine

@propertyWrapper struct Persist<T> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }

        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

final class MapViewController: UIViewController {

    // MARK: Outlets

    @IBOutlet private var mapView: MKMapView!

    // MARK: Private properties

    @Persist("isTracking", defaultValue: false) private var isTracking: Bool
    private let viewModel = MapViewModel()
    private var cancellable: AnyCancellable?

    // MARK: Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()

        subscribeToAuthorizationStatusChanges()
    }

    // MARK: Private methods

    private func subscribeToAuthorizationStatusChanges() {
        cancellable = viewModel.$authorizationStatus
            .sink { [weak self] status in
                guard let self, let status else { return }

                switch status {
                case .authorized:
                    if isTracking {
                        startTracking()
                    }
                default:
                    break
                }
            }
    }

    private func startTracking() {
        isTracking = true
        mapView.setUserTrackingMode(.follow, animated: true)
        viewModel.startUpdatingLocation()
    }

    private func stopTracking() {
        isTracking = false
        mapView.setUserTrackingMode(.none, animated: true)
        mapView.showsUserLocation = false
        viewModel.stopUpdatingLocation()
    }

    // MARK: Actions

    @IBAction private func startTrackingAction(_ sender: Any) {
        startTracking()
    }

    @IBAction private func stopTrackingAction(_ sender: Any) {
        stopTracking()
    }
}
