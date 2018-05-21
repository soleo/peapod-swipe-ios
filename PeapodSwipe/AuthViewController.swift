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
import Alamofire

class AuthViewController: UIViewController {

    var signInButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.Defaults.darkBackgroundColor

        // Login Screen
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "SquareLogo"))
        view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(view)
        }

        let signInButton = UIButton()
        signInButton.backgroundColor = UIColor.Defaults.primaryColor
        signInButton.setTitle(NSLocalizedString("Sign In", comment: "Sign In"), for: UIControlState())
        signInButton.setTitleColor(UIColor.white, for: UIControlState())
        signInButton.clipsToBounds = true
        signInButton.layer.cornerRadius = 5
        signInButton.layer.masksToBounds = true
        signInButton.addTarget(self, action: #selector(self.SELSignInWithEmail), for: UIControlEvents.touchUpInside)

        view.addSubview(signInButton)

        signInButton.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(50)
            make.width.equalTo(self.view).offset(-20)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-10)
            make.centerX.equalTo(self.view)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

    }
}

extension AuthViewController {
    func showMagicLinkAlert(email: String) {
        let alert = UIAlertController(title: "Check Your Mail Inbox", message: "A magic link has been sent to "+email, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Sure", comment: "Sure"), style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }

    func showRetryMessage() {
        let alert = UIAlertController(title: "Something Went Wrong", message: "Could retry your Email and invite code?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Ok"), style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }

    @objc func SELSignInWithEmail() {
        let alert = UIAlertController(title: NSLocalizedString("Sign In", comment: "Sign In"), message: "Your Email and invie code, Please?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "bagel.is.everything@ahold.com"
            textField.keyboardType = .emailAddress
            textField.returnKeyType = .done
        })

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "your invite code, like bagels"
            textField.autocorrectionType = .no
        })

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            let args = ProcessInfo.processInfo.arguments

            if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") || args.contains("UI_TEST_MODE") {
                Auth.auth().signInAnonymously(completion: { (user, error) in
                    let cardViewController = CardViewController()

                    let controller = UINavigationController(rootViewController: cardViewController)
                    return self.present(controller, animated: true, completion: nil)
                })

                return
            }

            if let email = alert.textFields?.first?.text?.trim() {
                //print("Your email: \(email)")
                if self.isValidEmail(emalAddress: email), let inviteCode = alert.textFields?.last?.text?.trim() {
                    Alamofire.request(
                        UserRouter.register(email, inviteCode)
                        )
                        .responseJSON { response in
                            if let httpStatusCode = response.response?.statusCode {
                                switch(httpStatusCode) {
                                case 409:
                                    // Send The Magic Link to User
                                    Alamofire.request(
                                        UserRouter.requestForMagicLink(email)
                                        )
                                        .response(completionHandler: { (response) in
                                            // show an alert to tell user to check their mailbox
                                            self.showMagicLinkAlert(email: email)
                                        })
                                    break
                                case 201:
                                    if let bearerToken = response.response?.allHeaderFields["Authorization"] as? String {
                                        print(bearerToken)
                                        let setting = UserSetting(email: email, token: bearerToken, isLoggedIn: true, skipIntro: false)
                                        let key: String = String(describing: UserSetting.self)
                                        UserDefaults.standard.df.store(setting, forKey: key)

                                        Auth.auth().createUser(withEmail: email, password: "ppod9ppod9", completion: { (user, error) in
                                            print("Sign In error: \(String(describing: error))")
                                            if error == nil {
                                                Analytics.logEvent("sign_up", parameters: [ "email": email, "invite_code": inviteCode ])
                                                let cardViewController = CardViewController()

                                                let controller = UINavigationController(rootViewController: cardViewController)
                                                return self.present(controller, animated: true, completion: nil)

                                            }
                                        })
                                    }
                                    break
                                default:
                                    self.showRetryMessage()
                                    print("peapod \(httpStatusCode)")
                                }
                            }
                    }

                }
            }
        }))

        self.present(alert, animated: true)
    }

    // Stack Overflow: https://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift#25471164
    private func isValidEmail(emalAddress: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emalAddress)
    }
}
