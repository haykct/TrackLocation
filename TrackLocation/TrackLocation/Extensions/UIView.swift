//
//  UIView.swift
//  TrackLocation
//
//  Created by Hayk Hayrapetyan on 22.02.24.
//

import UIKit

extension UIView {
    class func fromNib<T: UIView>() -> T? {
        Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)?[0] as? T
    }
}
