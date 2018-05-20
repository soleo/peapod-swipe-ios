//
//  SettingViewController.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 5/19/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import UIKit
import SnapKit

class SettingViewController: UIViewController {
    let dismissButton = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissButton.setTitle("Dismiss", for: .normal)
        //dismissButton.backgroundColor = .white
        dismissButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissViewController)))
        self.view.addSubview(dismissButton)

        dismissButton.snp.makeConstraints { (make) in
            make.center.equalTo(self.view)
            make.height.equalTo(100)
            make.width.equalTo(self.view)
        }

    }

    @objc func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
}
