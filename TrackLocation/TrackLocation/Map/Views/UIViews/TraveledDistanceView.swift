//
//  TraveledDistanceView.swift
//  TrackLocation
//
//  Created by Hayk Hayrapetyan on 22.02.24.
//

import UIKit

class TraveledDistanceView: UIView {

    // MARK: Outlets

    @IBOutlet private var distanceLabel: UILabel!
    @IBOutlet private var circleView: UIView!

    // MARK: Lifecycle methods

    override func layoutSubviews() {
        super.layoutSubviews()

        circleView.layer.cornerRadius = frame.width / 2
        circleView.layer.borderWidth = 5
        circleView.layer.borderColor = Colors.mapBlue.cgColor
    }

    // MARK: Public methods

    func updateDistanceText(_ text: String) {
        distanceLabel.text = text
    }
}
