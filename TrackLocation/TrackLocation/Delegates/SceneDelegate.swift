//
//  SceneDelegate.swift
//  TrackLocation
//
//  Created by Hayk Hayrapetyan on 17.02.24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        setupInitialViewController(windowScene: windowScene)
    }

    // It is always better to add view controller instantiation inside the coordinator,
    // however I created it here because my app is small and does not include navigation.
    private func setupInitialViewController(windowScene: UIWindowScene) {
        let locationService = Injection.shared.container.resolve(LocationService.self)!
        let viewModel = MapViewModel(locationService: locationService)
        let creator = { MapViewController(coder: $0, viewModel: viewModel) }
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let mapViewController = storyboard.instantiateViewController(identifier: "Map", creator: creator)

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = mapViewController
        window?.makeKeyAndVisible()
    }
}
