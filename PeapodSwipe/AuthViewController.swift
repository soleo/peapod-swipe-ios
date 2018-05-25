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

class AuthViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var inviteCodeField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        inviteCodeField.delegate = self
        view.backgroundColor = UIColor.Defaults.darkBackgroundColor
        UINavigationBar.appearance().barStyle = .blackOpaque
    }
// MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        //var email = textField.text
    }
// MARK: Action
    @IBAction func signInAction(_ sender: UIButton) {
        let email: String = emailField.text!.trim()
        let inviteCode: String = inviteCodeField.text!.trim()
        if !( self.isValidEmail(emalAddress: email) ) {
            emailField.layer.borderColor = UIColor.red.cgColor
            emailField.layer.borderWidth = 2.0
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
        if self.isDebugMode() {
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
                                self.clearTextFields()
                                // show an alert to tell user to check their mailbox
                                self.showOKAlert(title: "Check Your Mail Inbox",
                                                 message: "A magic link has been sent to " + email)
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
    private func isDebugMode() -> Bool {
        let args = ProcessInfo.processInfo.arguments
        return (UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") || args.contains("UI_TEST_MODE"))
    }
    private func clearTextFields() {
        emailField.text = ""
        inviteCodeField.text=""
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
