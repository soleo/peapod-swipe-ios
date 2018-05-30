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
    var emailField = UITextField()
    var inviteCodeField = UITextField()
    var signInButton = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.Defaults.darkBackgroundColor
        // Login Screen
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "SquareLogo"))
        view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(view)
        }
        //Email field
        emailField =  UITextField(frame: CGRect(x: 20, y: 285, width: 335, height: 40))
        emailField.placeholder = "Enter your email"
        emailField.font = UIFont.systemFont(ofSize: 15)
        emailField.borderStyle = .roundedRect
        emailField.autocorrectionType = UITextAutocorrectionType.no
        emailField.autocapitalizationType = UITextAutocapitalizationType.none
        emailField.keyboardType = UIKeyboardType.emailAddress
        emailField.returnKeyType = UIReturnKeyType.next
        emailField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        emailField.delegate = self as? UITextFieldDelegate
        emailField.backgroundColor = UIColor.Defaults.lightBackgroudColor
        emailField.alpha = 0.60
        //invite code field
        inviteCodeField =  UITextField(frame: CGRect(x: 20, y: 345, width: 335, height: 40))
        inviteCodeField.placeholder = "Enter your invite code"
        inviteCodeField.font = UIFont.systemFont(ofSize: 15)
        inviteCodeField.borderStyle = .roundedRect
        inviteCodeField.autocorrectionType = UITextAutocorrectionType.no
        inviteCodeField.autocapitalizationType = UITextAutocapitalizationType.none
        inviteCodeField.keyboardType = UIKeyboardType.emailAddress
        inviteCodeField.returnKeyType = UIReturnKeyType.next
        inviteCodeField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        inviteCodeField.delegate = self as? UITextFieldDelegate
        inviteCodeField.backgroundColor = UIColor.Defaults.lightBackgroudColor
        inviteCodeField.alpha = 0.60
        //sign in button 
        let signInButton = UIButton()
        signInButton.backgroundColor = UIColor.Defaults.primaryColor
        signInButton.setTitle(NSLocalizedString("Sign In", comment: "Sign In"), for: UIControlState())
        signInButton.setTitleColor(UIColor.white, for: UIControlState())
        signInButton.clipsToBounds = true
        signInButton.layer.cornerRadius = 5
        signInButton.layer.masksToBounds = true
        signInButton.addTarget(self, action: #selector(self.signInAction), for: UIControlEvents.touchUpInside)
        view.addSubview(emailField)
        view.addSubview(inviteCodeField)
        view.addSubview(signInButton)
        signInButton.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(50)
            make.width.equalTo(self.view).offset(-20)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-10)
            make.centerX.equalTo(self.view)
        }
    }

    @objc func signInAction(_ sender: UIButton) {
        let email: String = emailField.text!.trim()
        let inviteCode: String = inviteCodeField.text!.trim()
        if !( self.isValidEmail(emalAddress: email) ) {
            showOKAlert(title: "Something Went Wrong",
                        message: "The email address you entered is not valid. Please try again.")
        } else {
            self.signInWithEmail(email: email, inviteCode: inviteCode)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

    }
}

extension AuthViewController {
    func signInWithEmail(email: String, inviteCode: String) {
        if self.isTestMode() {
            Auth.auth().signInAnonymously(completion: { (_, _) in
                let cardViewController = CardViewController()
                let controller = UINavigationController(rootViewController: cardViewController)
                return self.present(controller, animated: true, completion: nil)
            })
            return
        }
        Alamofire.request(AuthRouter.register(email, inviteCode))
            .responseJSON { response in
                if let httpStatusCode = response.response?.statusCode {
                    switch httpStatusCode {
                    case 409:
                        // Send The Magic Link to User
                        Alamofire.request(AuthRouter.requestForMagicLink(email))
                            .response(completionHandler: { (_) in
                                // show an alert to tell user to check their mailbox
                                self.showOKAlert(title: "Check Your Mail Inbox",
                                                 message: "A magic link has been sent to " + email)
                                self.clearTextFields()
                            })
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
                    default:
                        self.showOKAlert(title: "Something Went Wrong",
                            message: "Please re-enter your email and invite code.")
                        self.clearTextFields()
                    }
                }
        } //end Alamofire.request
    }

    // Stack Overflow: https://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift#25471164
    private func isValidEmail(emalAddress: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emalAddress)
    }
    private func isTestMode() -> Bool {
        let args = ProcessInfo.processInfo.arguments
        return (UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") || args.contains("UI_TEST_MODE"))
    }
    private func clearTextFields() {
        emailField.text = ""
        inviteCodeField.text = ""
    }
    private func showOKAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
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
}
