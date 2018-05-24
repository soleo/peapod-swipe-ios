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
import Instabug

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
        let alert = UIAlertController(
            title: "Check Your Mail Inbox",
            message: "A magic link has been sent to " + email,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("OK", comment: "OK"),
                style: .cancel,
                handler: nil
            )
        )
        self.present(alert, animated: true)
    }

    func showRetryMessage() {
        let alert = UIAlertController(
            title: "Something Went Wrong",
            message: "Please re-enter your email and invite code.",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("OK", comment: "Ok"),
                style: .cancel,
                handler: nil
            )
        )
        self.present(alert, animated: true)
    }
    
    func showInvalidEmailMessage() {
        let alert = UIAlertController(
            title: "Something Went Wrong",
            message: "The email address you entered is not valid. Please try again.",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("OK", comment: "Ok"),
                style: .cancel,
                handler: nil
            )
        )
        self.present(alert, animated: true)
    }

    @objc func SELSignInWithEmail() {
        let alert = UIAlertController(
            title: NSLocalizedString("Sign In", comment: "Sign In"),
            message: "Enter Your Email and Invite Code",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Cancel", comment: "Cancel"),
                style: .cancel,
                handler: nil
            )
        )

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "bagel.is.everything@ahold.com"
            textField.keyboardType = .emailAddress
            textField.returnKeyType = .done
        })

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "your invite code, like bagels"
            textField.autocorrectionType = .no
        })

        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default,
                handler: { _ in
            let args = ProcessInfo.processInfo.arguments

            if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") || args.contains("UI_TEST_MODE") {
                Auth.auth().signInAnonymously(completion: { (_, _) in
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
                            AuthRouter.register(email, inviteCode)
                        )
                        .responseJSON { response in
                            if let httpStatusCode = response.response?.statusCode {
                                switch httpStatusCode {
                                case 409:
                                    // Send The Magic Link to User
                                    Alamofire.request(
                                        AuthRouter.requestForMagicLink(email)
                                        )
                                        .response(completionHandler: { (_) in
                                            // show an alert to tell user to check their mailbox
                                            self.showMagicLinkAlert(email: email)
                                        })
                                    break
                                case 201:
                                    if let bearerToken = response.response?.allHeaderFields["Authorization"] as? String {
                                        //print(bearerToken)
                                        let setting = UserInfo(email: email, token: bearerToken, inviteCode: inviteCode, isLoggedIn: true, skipIntro: false)
                                        let key: String = String(describing: UserInfo.self)
                                        UserDefaults.standard.df.store(setting, forKey: key)

                                        Auth.auth().createUser(withEmail: email, password: "ppod9ppod9", completion: { (_, error) in
                                            //print("Sign In error: \(String(describing: error))")
                                            if error == nil {
                                                Analytics.logEvent("sign_up", parameters: [ "email": email, "invite_code": inviteCode ])
                                                Instabug.identifyUser(withEmail: email, name: email)
                                                Instabug.setUserAttribute(inviteCode, withKey: "Invite Code")
                                                let cardViewController = CardViewController()

                                                let controller = UINavigationController(rootViewController: cardViewController)
                                                return self.present(controller, animated: true, completion: nil)

                                            }
                                        })
                                    }
                                    break
                                default:
                                    self.showRetryMessage()

                                }
                            }
                    }

                }else {
                    self.showInvalidEmailMessage()
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
