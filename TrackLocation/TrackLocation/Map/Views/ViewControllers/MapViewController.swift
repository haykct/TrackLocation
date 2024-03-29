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
    @IBOutlet private var enableLocationButton: UIButton!

    // MARK: Private properties

    private static let buttonCornerRadius: CGFloat = 10
    private let viewModel: MapViewModel

    // A boolean flag used to retain the tracking state after an app relaunch or authorization status change.
    @Persisted(UserDefaultsKeys.shouldTrack, defaultValue: false) private var shouldTrack: Bool
    private var traveledDistanceView: TraveledDistanceView?
    private var cancellables = Set<AnyCancellable>()
    private var alertTitle = ""
    private var alertMessage = ""

    // MARK: Initializers

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("Use `init(coder:viewModel:)` to initialize a `MapViewController` instance.")
    }

    // Initializer, for passing parameters to ViewController initialized from storyboard.
    init?(coder: NSCoder, viewModel: MapViewModel) {
        self.viewModel = viewModel

        super.init(coder: coder)
    }

    // MARK: Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMapView()
        setupButtons()
        setupTraveledDistanceView()
        subscribeToViewModelUpdates()
    }

    // MARK: Private methods

    private func subscribeToViewModelUpdates() {
        viewModel.$authorizationStatus
            .sink { [weak self] status in
                guard let self, let status else { return }

                handleMainFlowChanges(when: status)
            }
            .store(in: &cancellables)

        viewModel.$mapViewData
            .sink { [weak self] viewData in
                self?.traveledDistanceView?.updateDistanceText(viewData.traveledDistance)
            }
            .store(in: &cancellables)
    }

    private func handleMainFlowChanges(when status: AuthorizationStatus) {
        if status != .authorized {
            stopTracking()
        }

        switch status {
        case .authorized:
            changeButtonVisibility(isLocationEnabled: true)

            if shouldTrack {
                startTracking()
            }
        case .notDetermined:
            changeButtonVisibility(isLocationEnabled: true)
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
        mapView.setUserTrackingMode(.follow, animated: true)
        viewModel.startUpdatingLocation()
    }

    private func stopTracking() {
        mapView.showsUserLocation = false
        mapView.setUserTrackingMode(.none, animated: true)
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

    private func setupTraveledDistanceView() {
        guard let distanceView: TraveledDistanceView = .fromNib() else { return }

        distanceView.frame = CGRect(x: 40, y: 150, width: 90, height: 130)
        view.addSubview(distanceView)
        traveledDistanceView = distanceView
    }

    private func setupLocationAlertDescription(title: String, message: String) {
        alertTitle = title
        alertMessage = message
    }

    private func changeButtonVisibility(isLocationEnabled: Bool) {
        startTrackingButton.isHidden = !isLocationEnabled
        stopTrackingButton.isHidden = !isLocationEnabled
        enableLocationButton.isHidden = isLocationEnabled
        traveledDistanceView?.isHidden = !isLocationEnabled
    }

    // In case of unauthorized access to location data this method opens user settings and
    // asks the user to enable location services.
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
        shouldTrack = true
        startTracking()
    }

    @IBAction private func stopTrackingAction(_ sender: Any) {
        shouldTrack = false
        stopTracking()
        viewModel.resetDistance()
    }

    @IBAction func enableLocationAction(_ sender: Any) {
        openLocationAlert()
    }
}
