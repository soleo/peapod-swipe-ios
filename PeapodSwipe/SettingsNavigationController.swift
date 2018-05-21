//
//  SettingsNavigationController.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 5/20/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import UIKit

class SettingsNavigationController: UINavigationController {
    var popoverDelegate: PresentingModalViewControllerDelegate?

    @objc func done() {
        if let delegate = popoverDelegate {
            delegate.dismissPresentedModalViewController(self, animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

protocol PresentingModalViewControllerDelegate {
    func dismissPresentedModalViewController(_ modalViewController: UIViewController, animated: Bool)
}

class ModalSettingsNavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}
