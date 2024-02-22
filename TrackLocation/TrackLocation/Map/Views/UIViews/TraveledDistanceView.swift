//
//  TraveledDistanceView.swift
//  TrackLocation
//
//  Created by Hayk Hayrapetyan on 22.02.24.
//

import UIKit

class TraveledDistanceView: UIView {

    // MARK: Outlets

    @IBOutlet weak var distanceLabel: UILabel!

    // MARK: Lifecycle methods

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.cornerRadius = frame.width / 2
        layer.borderWidth = 5
        layer.borderColor = Colors.mapBlue.cgColor
    }
}
