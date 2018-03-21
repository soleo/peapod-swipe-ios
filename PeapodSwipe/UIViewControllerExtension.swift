//
//  UIViewControllerExtension.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 3/17/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import UIKit

extension UIViewController {

    #if DEBUG
    @objc func injected() {
        for subview in self.view.subviews {
            subview.removeFromSuperview()
        }

        if let sublayers = self.view.layer.sublayers {
            for sublayer in sublayers {
                sublayer.removeFromSuperlayer()
            }
        }

        viewDidLoad()
    }
    #endif
}
