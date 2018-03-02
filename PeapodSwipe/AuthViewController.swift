//
//  AuthViewController.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 11/25/17.
//  Copyright © 2017 Xinjiang Shao. All rights reserved.
//

import UIKit
import Firebase

class AuthViewController: UIViewController {
    
    var signInButton: UIButton!
    var mainViewController: CardViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.Defaults.backgroundColor
        
        // Login Screen
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "SquareLogo"))
        view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(view)
        }
        
        let signInButton = UIButton()
        signInButton.backgroundColor = UIColor.Defaults.primaryColor
        signInButton.setTitle("Sign In", for: UIControlState())
        signInButton.setTitleColor(UIColor.white, for: UIControlState())
        signInButton.clipsToBounds = true
        signInButton.addTarget(self, action: #selector(self.SELsignInAnonymously), for: UIControlEvents.touchUpInside)
    
        view.addSubview(signInButton)
        
        signInButton.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(50)
            make.width.equalTo(view.frame.width - 20*2)
            make.bottom.equalTo(view).offset(-20)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.centerX.equalTo(view)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension AuthViewController{
    @objc func SELsignInAnonymously() {
        
        return Auth.auth().signInAnonymously() { (user, error) in
            // ...
            // print(user)
           Analytics.logEvent("sign_in", parameters: nil)
           let cardViewController = CardViewController()
           return self.present(cardViewController, animated: true, completion: nil)
        }
    }
}
