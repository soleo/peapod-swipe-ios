//
//  AppSettingsTableViewController.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 5/20/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import UIKit

class AppSettingsTableViewController: SettingsTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = NSLocalizedString("Settings", comment: "Title in the settings view controller title bar")
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Done", comment: "Done button on left side of the Settings view controller title bar"),
            style: .done,
            target: navigationController, action: #selector((navigationController as! SettingsNavigationController).done))
        navigationItem.leftBarButtonItem?.accessibilityIdentifier = "AppSettingsTableViewController.navigationItem.leftBarButtonItem"
        tableView.accessibilityIdentifier = "AppSettingsTableViewController.tableView"

    }

    override func generateSettings() -> [SettingSection] {
        var settings = [SettingSection]()

        let generalSection = SettingSection(title: NSAttributedString(string: NSLocalizedString("General", comment: "General section title")), children: [
             ShowEmailSetting(settings: self),
             ShowInviteCodeSetting(settings: self)
        ])
        let supportSection = SettingSection(title: NSAttributedString(string: NSLocalizedString("Support", comment: "Support section title")), children: [
            ShowIntroductionSetting(settings: self),
            SendFeedbackSetting()
        ])
        let aboutSection = SettingSection(title: NSAttributedString(string: NSLocalizedString("About", comment: "About settings section title")), children: [
            VersionSetting(settings: self),
            PrivacyPolicySetting()
        ])
        let logoutSection = SettingSection(title: nil, children: [
            LogoutSetting(settings: self)
        ])

        settings += [
            generalSection,
            supportSection,
            aboutSection,
            logoutSection
        ]
        return settings
    }
}
