//
//  AuthViewController.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 11/25/17.
//  Copyright © 2017 Xinjiang Shao. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

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
        signInButton.addTarget(self, action: #selector(self.SELSignInWithEmail), for: UIControlEvents.touchUpInside)
    
        view.addSubview(signInButton)
        
        signInButton.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(50)
            make.width.equalTo(300)
            make.bottom.equalTo(view).offset(-20)
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
    
    @objc func SELSignInWithEmail() {
        let alert = UIAlertController(title: "What's your work Email address?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "bagel.is.everything@ahold.com"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            if let email = alert.textFields?.first?.text?.trim() {
                print("Your email: \(email)")
                if self.isValidEmail(emalAddress: email) {
                    Auth.auth().signIn(withEmail: email , password: "ppod9ppod9", completion: { (user, error) in
                        if error != nil {
                            print("Sign In error: \(String(describing: error))")
                            Auth.auth().createUser(withEmail: email, password: "ppod9ppod9", completion: { (user, error) in
                                print("Sign In error: \(String(describing: error))")
                                if error == nil {
                                    Analytics.logEvent("sign_up", parameters: [ "email": email ])
                                    let cardViewController = CardViewController()
                                    return self.present(cardViewController, animated: true, completion: nil)
                                }
                            })
                            
                        } else {
                            Analytics.logEvent("sign_in", parameters: [ "email": email ])
                            let cardViewController = CardViewController()
                            return self.present(cardViewController, animated: true, completion: nil)
                        }
                        
                        
                        
                    })
                }
            }
        }))
        
        self.present(alert, animated: true)
    }
    
    // Stack Overflow: https://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift#25471164
    private func isValidEmail(emalAddress:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emalAddress)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
