//
//  ViewController.swift
//  TrackLocation
//
//  Created by Hayk Hayrapetyan on 17.02.24.
//

import UIKit
import MapKit
import Combine

final class MapViewController: UIViewController, MKMapViewDelegate {

    // MARK: Outlets

    @IBOutlet private var mapView: MKMapView!
    @IBOutlet private var startTrackingButton: UIButton!
    @IBOutlet private var stopTrackingButton: UIButton!
    @IBOutlet weak var enableLocationButton: UIButton!

    // MARK: Private properties

    private static let buttonCornerRadius: CGFloat = 10

    @Persisted("isTracking", defaultValue: false) private var isTracking: Bool
    private let viewModel = MapViewModel(locationService: Injection.shared.container.resolve(LocationService.self)!)
    private var cancellable: AnyCancellable?
    private var alertTitle = ""
    private var alertMessage = ""

    // MARK: Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMapView()
        setupButtons()
        subscribeToAuthorizationStatusChanges()
    }

    // MARK: Private methods

    private func subscribeToAuthorizationStatusChanges() {
        cancellable = viewModel.$authorizationStatus
            .sink { [weak self] status in
                guard let self, let status else { return }

                handleMainFlowChanges(when: status)
            }
    }
    private func handleMainFlowChanges(when status: AuthorizationStatus) {
        switch status {
        case .authorized:
            changeButtonVisibility(isLocationEnabled: true)

            if isTracking {
                startTracking()
            }
        case .notDetermined:
            changeButtonVisibility(isLocationEnabled: true)

            if isTracking {
                // This is the case when user chooses "allow once" permission and starts tracking.
                // When the app is reopened, the status will be notDetermined,
                // but the isTracking flag will still be true.
                isTracking = false
            }
        case .appLocationDenied:
            setupLocationAlertDescription(title: LocalizationKeys.appLocationOff,
                                  message: LocalizationKeys.turnOnLocationSettings)
            changeButtonVisibility(isLocationEnabled: false)
        case .locationServicesDenied:
            setupLocationAlertDescription(title: LocalizationKeys.locationServicesOff,
                                  message: LocalizationKeys.turnOnLocationServices)
            changeButtonVisibility(isLocationEnabled: false)
        case .restricted:
            setupLocationAlertDescription(title: LocalizationKeys.locationRestricted,
                                  message: LocalizationKeys.changeRestrictionSettings)
            changeButtonVisibility(isLocationEnabled: false)
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

    private func setupMapView() {
        mapView.camera.centerCoordinate = CLLocationCoordinate2D(latitude: Coordinates.initialLatitude,
                                                                 longitude: Coordinates.initialLongitude)
        mapView.camera.centerCoordinateDistance = .greatestFiniteMagnitude
    }

    private func setupButtons() {
        startTrackingButton.layer.cornerRadius = Self.buttonCornerRadius
        stopTrackingButton.layer.cornerRadius = Self.buttonCornerRadius
        enableLocationButton.layer.cornerRadius = enableLocationButton.bounds.size.height / 2
        startTrackingButton.setTitle(LocalizationKeys.startTracking, for: .normal)
        stopTrackingButton.setTitle(LocalizationKeys.stopTracking, for: .normal)
        enableLocationButton.setTitle(LocalizationKeys.enableLocation, for: .normal)
    }

    private func setupLocationAlertDescription(title: String, message: String) {
        alertTitle = title
        alertMessage = message
    }

    private func changeButtonVisibility(isLocationEnabled: Bool) {
        startTrackingButton.isHidden = !isLocationEnabled
        stopTrackingButton.isHidden = !isLocationEnabled
        enableLocationButton.isHidden = isLocationEnabled
    }

    private func openLocationSettings() {
        switch viewModel.authorizationStatus {
        case .appLocationDenied:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        case .locationServicesDenied, .restricted:
            if let url = URL(string: "App-prefs:Privacy") {
                UIApplication.shared.open(url)
            }
        default:
            break
        }
    }

    private func openLocationAlert() {
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: LocalizationKeys.cancel, style: .default)
        let settingsAction = UIAlertAction(title: LocalizationKeys.settings, style: .default) { [weak self] _ in
            self?.openLocationSettings()
        }

        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    // MARK: Actions

    @IBAction private func startTrackingAction(_ sender: Any) {
        startTracking()
    }

    @IBAction private func stopTrackingAction(_ sender: Any) {
        stopTracking()
    }

    @IBAction func enableLocationAction(_ sender: Any) {
        openLocationAlert()
    }
}
