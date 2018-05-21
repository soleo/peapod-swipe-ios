//
//  AppSettingsOptions.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 5/20/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import UIKit
import Firebase
import Default

// Logout the app
class LogoutSetting: Setting {

    override var textAlignment: NSTextAlignment { return .center }

    override var accessibilityIdentifier: String? { return "Logout" }

    init(settings: SettingsTableViewController) {
        let title = NSAttributedString(string: NSLocalizedString("Log Out", comment: "Logout Curren User"), attributes: [
            NSAttributedStringKey.foregroundColor: UIColor.Defaults.secondaryColor
        ])
        super.init(title: title)
    }

    override func onClick(_ navigationController: UINavigationController?) {
        navigationController?.dismiss(animated: true, completion: {
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }

            Analytics.logEvent("log_out", parameters: nil)
            if let rootVC = UIApplication.shared.delegate?.window??.rootViewController {
                rootVC.dismiss(animated: true, completion: nil)
            }
        })
    }

}

// Show User Info
class ShowInviteCodeSetting: Setting {

    override var accessibilityIdentifier: String? { return "InviteCode" }
    override var status: NSAttributedString? {
        let key = String(describing: UserInfo.self)
        if let settings = UserDefaults.standard.df.fetch(forKey: key, type: UserInfo.self) {
            return NSAttributedString(string: NSLocalizedString(settings.inviteCode.uppercased(), comment: "Invite Code"), attributes: [NSAttributedStringKey.foregroundColor: UIColor.Defaults.primaryTextColor])
        }
        return nil
    }
    init(settings: SettingsTableViewController) {
        super.init(title: NSAttributedString(string: NSLocalizedString("Invite Code", comment: "Show user information like email address, nickname etc"), attributes: [NSAttributedStringKey.foregroundColor: UIColor.Defaults.primaryTextColor]))
    }

}

class ShowEmailSetting: Setting {

    override var accessibilityIdentifier: String? { return "Email" }
    override var status: NSAttributedString? {
        let key = String(describing: UserInfo.self)
        if let settings = UserDefaults.standard.df.fetch(forKey: key, type: UserInfo.self) {
            return NSAttributedString(string: NSLocalizedString(settings.email, comment: "Email"), attributes: [NSAttributedStringKey.foregroundColor: UIColor.Defaults.primaryTextColor])
        }
        return nil
    }
    init(settings: SettingsTableViewController) {
        super.init(title: NSAttributedString(string: NSLocalizedString("Email", comment: "Show user information like email address, nickname etc"), attributes: [NSAttributedStringKey.foregroundColor: UIColor.Defaults.primaryTextColor]))
    }

}
// Opens the on-boarding screen again
class ShowIntroductionSetting: Setting {

    override var accessibilityIdentifier: String? { return "ShowTour" }

    init(settings: SettingsTableViewController) {

        super.init(title: NSAttributedString(string: NSLocalizedString("Show Tour", comment: "Show the on-boarding screen again from the settings"), attributes: [NSAttributedStringKey.foregroundColor: UIColor.Defaults.primaryTextColor]))
    }

    override func onClick(_ navigationController: UINavigationController?) {
        navigationController?.dismiss(animated: true, completion: {
//            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//                // show on boarding tour
//
//                //appDelegate.browserViewController.presentIntroViewController(true)
//            }
        })
    }
}

class SendFeedbackSetting: Setting {
    override var title: NSAttributedString? {
        return NSAttributedString(string: NSLocalizedString("Send Feedback", comment: "Menu item in settings used to open input.mozilla.org where people can submit feedback"), attributes: [NSAttributedStringKey.foregroundColor: UIColor.Defaults.primaryTextColor])
    }

    override var url: URL? {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        return URL(string: "https://github.com/soleo/peapod-swipe-ios/issues/new?title=v\(appVersion)_feedback")
    }

    override func onClick(_ navigationController: UINavigationController?) {
        setUpAndPushSettingsContentViewController(navigationController)
    }
}

// Show the current version of Firefox
class VersionSetting: Setting {
    unowned let settings: SettingsTableViewController

    override var accessibilityIdentifier: String? { return "PeapodSwipeVersion" }

    init(settings: SettingsTableViewController) {
        self.settings = settings
        super.init(title: nil)
    }

    override var title: NSAttributedString? {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        return NSAttributedString(string: String(format: NSLocalizedString("Version %@ (%@)", comment: "Version number of Peapod Swipe shown in settings"), appVersion, buildNumber), attributes: [NSAttributedStringKey.foregroundColor:UIColor.Defaults.primaryTextColor ])
    }

    override func onConfigureCell(_ cell: UITableViewCell) {
        super.onConfigureCell(cell)
        cell.selectionStyle = .none
    }

}

// Opens the the term of service page in a new tab
class PrivacyPolicySetting: Setting {
    override var title: NSAttributedString? {
        return NSAttributedString(string: NSLocalizedString("Peapod's Privacy Policy", comment: "Settings item that opens a tab containing the term of service."), attributes: [NSAttributedStringKey.foregroundColor: UIColor.Defaults.primaryTextColor])
    }

    override var url: URL? {
        return URL(string: "https://about.peapod.com/privacy-policy/")
    }

    override func onClick(_ navigationController: UINavigationController?) {
        setUpAndPushSettingsContentViewController(navigationController)
    }
}
