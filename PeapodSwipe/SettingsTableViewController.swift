//
//  SettingViewController.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 5/19/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import UIKit
import SnapKit
import SafariServices

@objc
protocol SettingsDelegate: class {
    func settingsOpenURLInNewTab(_ url: URL)
}

// A base setting class that shows a title. You probably want to subclass this, not use it directly.
class Setting: NSObject {
    fileprivate var _title: NSAttributedString?
    fileprivate var _footerTitle: NSAttributedString?
    fileprivate var _cellHeight: CGFloat?
    fileprivate var _image: UIImage?

    weak var delegate: SettingsDelegate?

    // The url the SFSafariViewController will show, e.g. Licenses and Privacy Policy.
    var url: URL? { return nil }

    // The title shown on the pref.
    var title: NSAttributedString? { return _title }
    var footerTitle: NSAttributedString? { return _footerTitle }
    var cellHeight: CGFloat? { return _cellHeight}
    fileprivate(set) var accessibilityIdentifier: String?

    // An optional second line of text shown on the pref.
    var status: NSAttributedString? { return nil }

    // Whether or not to show this pref.
    var hidden: Bool { return false }

    var style: UITableViewCellStyle { return .subtitle }

    var accessoryType: UITableViewCellAccessoryType { return .none }

    var textAlignment: NSTextAlignment { return .natural }

    var image: UIImage? { return _image }

    fileprivate(set) var enabled: Bool = true

    // Called when the cell is setup. Call if you need the default behaviour.
    func onConfigureCell(_ cell: UITableViewCell) {
        cell.detailTextLabel?.attributedText = status
        cell.detailTextLabel?.numberOfLines = 0
        cell.textLabel?.attributedText = title
        cell.textLabel?.textAlignment = textAlignment
        cell.textLabel?.numberOfLines = 1
        cell.textLabel?.lineBreakMode = .byTruncatingTail
        cell.accessoryType = accessoryType
        cell.accessoryView = nil
        cell.selectionStyle = enabled ? .default : .none
        cell.accessibilityIdentifier = accessibilityIdentifier
        cell.imageView?.image = _image
        if let title = title?.string {
            if let detailText = cell.detailTextLabel?.text {
                cell.accessibilityLabel = "\(title), \(detailText)"
            } else if let status = status?.string {
                cell.accessibilityLabel = "\(title), \(status)"
            } else {
                cell.accessibilityLabel = title
            }
        }
        cell.accessibilityTraits = UIAccessibilityTraitButton
        cell.indentationWidth = 0
        cell.layoutMargins = .zero
        // So that the separator line goes all the way to the left edge.
        cell.separatorInset = .zero
    }

    // Called when the pref is tapped.
    func onClick(_ navigationController: UINavigationController?) { return }

    // Helper method to set up and push a SettingsContentViewController
    func setUpAndPushSettingsContentViewController(_ navigationController: UINavigationController?) {

        if let url = self.url {
            let viewController = SFSafariViewController(url: url)
            viewController.dismissButtonStyle = .close
            viewController.configuration.barCollapsingEnabled = true
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    init(title: NSAttributedString? = nil, footerTitle: NSAttributedString? = nil, cellHeight: CGFloat? = nil, delegate: SettingsDelegate? = nil, enabled: Bool? = nil) {
        self._title = title
        self._footerTitle = footerTitle
        self._cellHeight = cellHeight
        self.delegate = delegate
        self.enabled = enabled ?? true
    }
}

// A setting in the sections panel. Contains a sublist of Settings
class SettingSection: Setting {
    fileprivate let children: [Setting]

    init(title: NSAttributedString? = nil, footerTitle: NSAttributedString? = nil, cellHeight: CGFloat? = nil, children: [Setting]) {
        self.children = children
        super.init(title: title, footerTitle: footerTitle, cellHeight: cellHeight)
    }

    var count: Int {
        var count = 0
        for setting in children where !setting.hidden {
            count += 1
        }
        return count
    }

    subscript(val: Int) -> Setting? {
        var i = 0
        for setting in children where !setting.hidden {
            if i == val {
                return setting
            }
            i += 1
        }
        return nil
    }
}

private class PaddedSwitch: UIView {
    fileprivate static let Padding: CGFloat = 8

    init(switchView: UISwitch) {
        super.init(frame: .zero)

        addSubview(switchView)

        frame.size = CGSize(width: switchView.frame.width + PaddedSwitch.Padding, height: switchView.frame.height)
        switchView.frame.origin = CGPoint(x: PaddedSwitch.Padding, y: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// A helper class for settings with a UISwitch.
// Takes and optional settingsDidChange callback and status text.
//class BoolSetting: Setting {
//    let prefKey: String? // Sometimes a subclass will manage its own pref setting. In that case the prefkey will be nil
//
//    fileprivate let prefs: Prefs
//    fileprivate let defaultValue: Bool
//    fileprivate let settingDidChange: ((Bool) -> Void)?
//    fileprivate let statusText: NSAttributedString?
//
//    init(prefs: Prefs, prefKey: String? = nil, defaultValue: Bool, attributedTitleText: NSAttributedString, attributedStatusText: NSAttributedString? = nil, settingDidChange: ((Bool) -> Void)? = nil) {
//        self.prefs = prefs
//        self.prefKey = prefKey
//        self.defaultValue = defaultValue
//        self.settingDidChange = settingDidChange
//        self.statusText = attributedStatusText
//        super.init(title: attributedTitleText)
//    }
//
//    convenience init(prefs: Prefs, prefKey: String? = nil, defaultValue: Bool, titleText: String, statusText: String? = nil, settingDidChange: ((Bool) -> Void)? = nil) {
//        var statusTextAttributedString: NSAttributedString?
//        if let statusTextString = statusText {
//            statusTextAttributedString = NSAttributedString(string: statusTextString, attributes: [NSAttributedStringKey.foregroundColor: SettingsUX.TableViewHeaderTextColor])
//        }
//        self.init(prefs: prefs, prefKey: prefKey, defaultValue: defaultValue, attributedTitleText: NSAttributedString(string: titleText, attributes: [NSAttributedStringKey.foregroundColor: SettingsUX.TableViewRowTextColor]), attributedStatusText: statusTextAttributedString, settingDidChange: settingDidChange)
//    }
//
//    override var status: NSAttributedString? {
//        return statusText
//    }
//
//    override func onConfigureCell(_ cell: UITableViewCell) {
//        super.onConfigureCell(cell)
//
//        let control = UISwitch()
//        control.onTintColor = UIConstants.SystemBlueColor
//        control.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
//        control.accessibilityIdentifier = prefKey
//
//        displayBool(control)
//        if let title = title {
//            if let status = status {
//                control.accessibilityLabel = "\(title.string), \(status.string)"
//            } else {
//                control.accessibilityLabel = title.string
//            }
//            cell.accessibilityLabel = nil
//        }
//        cell.accessoryView = PaddedSwitch(switchView: control)
//        cell.selectionStyle = .none
//    }
//
//    @objc func switchValueChanged(_ control: UISwitch) {
//        writeBool(control)
//        settingDidChange?(control.isOn)
//        UnifiedTelemetry.recordEvent(category: .action, method: .change, object: .setting, value: self.prefKey, extras: ["to": control.isOn])
//    }
//
//    // These methods allow a subclass to control how the pref is saved
//    func displayBool(_ control: UISwitch) {
//        guard let key = prefKey else {
//            return
//        }
//        control.isOn = prefs.boolForKey(key) ?? defaultValue
//    }
//
//    func writeBool(_ control: UISwitch) {
//        guard let key = prefKey else {
//            return
//        }
//        prefs.setBool(control.isOn, forKey: key)
//    }
//}
//
//class PrefPersister: SettingValuePersister {
//    fileprivate let prefs: Prefs
//    let prefKey: String
//
//    init(prefs: Prefs, prefKey: String) {
//        self.prefs = prefs
//        self.prefKey = prefKey
//    }
//
//    func readPersistedValue() -> String? {
//        return prefs.stringForKey(prefKey)
//    }
//
//    func writePersistedValue(value: String?) {
//        if let value = value {
//            prefs.setString(value, forKey: prefKey)
//        } else {
//            prefs.removeObjectForKey(prefKey)
//        }
//    }
//}
//
//class StringPrefSetting: StringSetting {
//    init(prefs: Prefs, prefKey: String, defaultValue: String? = nil, placeholder: String, accessibilityIdentifier: String, settingIsValid isValueValid: ((String?) -> Bool)? = nil, settingDidChange: ((String?) -> Void)? = nil) {
//        super.init(defaultValue: defaultValue, placeholder: placeholder, accessibilityIdentifier: accessibilityIdentifier, persister: PrefPersister(prefs: prefs, prefKey: prefKey), settingIsValid: isValueValid, settingDidChange: settingDidChange)
//    }
//}
//
//protocol SettingValuePersister {
//    func readPersistedValue() -> String?
//    func writePersistedValue(value: String?)
//}

/// A helper class for a setting backed by a UITextField.
/// This takes an optional settingIsValid and settingDidChange callback
/// If settingIsValid returns false, the Setting will not change and the text remains red.
//class StringSetting: Setting, UITextFieldDelegate {
//
//    var Padding: CGFloat = 8
//
//    fileprivate let defaultValue: String?
//    fileprivate let placeholder: String
//    fileprivate let settingDidChange: ((String?) -> Void)?
//    fileprivate let settingIsValid: ((String?) -> Bool)?
//    fileprivate let persister: SettingValuePersister
//
//    let textField = UITextField()
//
//    init(defaultValue: String? = nil, placeholder: String, accessibilityIdentifier: String, persister: SettingValuePersister, settingIsValid isValueValid: ((String?) -> Bool)? = nil, settingDidChange: ((String?) -> Void)? = nil) {
//        self.defaultValue = defaultValue
//        self.settingDidChange = settingDidChange
//        self.settingIsValid = isValueValid
//        self.placeholder = placeholder
//        self.persister = persister
//
//        super.init()
//        self.accessibilityIdentifier = accessibilityIdentifier
//    }
//
//    override func onConfigureCell(_ cell: UITableViewCell) {
//        super.onConfigureCell(cell)
//        if let id = accessibilityIdentifier {
//            textField.accessibilityIdentifier = id + "TextField"
//        }
//        textField.placeholder = placeholder
//        textField.textAlignment = .center
//        textField.delegate = self
//        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
//        cell.isUserInteractionEnabled = true
//        cell.accessibilityTraits = UIAccessibilityTraitNone
//        cell.contentView.addSubview(textField)
//
//        textField.snp.makeConstraints { make in
//            make.height.equalTo(44)
//            make.trailing.equalTo(cell.contentView).offset(-Padding)
//            make.leading.equalTo(cell.contentView).offset(Padding)
//        }
//        textField.text = self.persister.readPersistedValue() ?? defaultValue
//        textFieldDidChange(textField)
//    }
//
//    override func onClick(_ navigationController: UINavigationController?) {
//        textField.becomeFirstResponder()
//    }
//
//    fileprivate func isValid(_ value: String?) -> Bool {
//        guard let test = settingIsValid else {
//            return true
//        }
//        return test(prepareValidValue(userInput: value))
//    }
//
//    /// This gives subclasses an opportunity to treat the user input string
//    /// before it is saved or tested.
//    /// Default implementation does nothing.
//    func prepareValidValue(userInput value: String?) -> String? {
//        return value
//    }
//
//    @objc func textFieldDidChange(_ textField: UITextField) {
//        let color = isValid(textField.text) ? SettingsUX.TableViewRowTextColor : UIConstants.DestructiveRed
//        textField.textColor = color
//    }
//
//    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        return isValid(textField.text)
//    }
//
//    @objc func textFieldDidEndEditing(_ textField: UITextField) {
//        let text = textField.text
//        if !isValid(text) {
//            return
//        }
//        self.persister.writePersistedValue(value: prepareValidValue(userInput: text))
//        // Call settingDidChange with text or nil.
//        settingDidChange?(text)
//    }
//}
//
//class CheckmarkSetting: Setting {
//    let onChanged: () -> Void
//    let isEnabled: () -> Bool
//    private let subtitle: NSAttributedString?
//
//    override var status: NSAttributedString? {
//        return subtitle
//    }
//
//    init(title: NSAttributedString, subtitle: NSAttributedString?, accessibilityIdentifier: String? = nil, isEnabled: @escaping () -> Bool, onChanged: @escaping () -> Void) {
//        self.subtitle = subtitle
//        self.onChanged = onChanged
//        self.isEnabled = isEnabled
//        super.init(title: title)
//        self.accessibilityIdentifier = accessibilityIdentifier
//    }
//
//    override func onConfigureCell(_ cell: UITableViewCell) {
//        super.onConfigureCell(cell)
//        cell.accessoryType = .checkmark
//        cell.tintColor = isEnabled() ? SettingsUX.TableViewRowActionAccessoryColor : UIColor.white
//    }
//
//    override func onClick(_ navigationController: UINavigationController?) {
//        // Force editing to end for any focused text fields so they can finish up validation first.
//        navigationController?.view.endEditing(true)
//        if !isEnabled() {
//            onChanged()
//        }
//    }
//}

/// A helper class for a setting backed by a UITextField.
/// This takes an optional isEnabled and mandatory onClick callback
/// isEnabled is called on each tableview.reloadData. If it returns
/// false then the 'button' appears disabled.
//class ButtonSetting: Setting {
//    let onButtonClick: (UINavigationController?) -> Void
//    let destructive: Bool
//    let isEnabled: (() -> Bool)?
//
//    init(title: NSAttributedString?, destructive: Bool = false, accessibilityIdentifier: String, isEnabled: (() -> Bool)? = nil, onClick: @escaping (UINavigationController?) -> Void) {
//        self.onButtonClick = onClick
//        self.destructive = destructive
//        self.isEnabled = isEnabled
//        super.init(title: title)
//        self.accessibilityIdentifier = accessibilityIdentifier
//    }
//
//    override func onConfigureCell(_ cell: UITableViewCell) {
//        super.onConfigureCell(cell)
//
//        if isEnabled?() ?? true {
//            cell.textLabel?.textColor = destructive ? UIConstants.DestructiveRed : UIConstants.HighlightBlue
//        } else {
//            cell.textLabel?.textColor = SettingsUX.TableViewDisabledRowTextColor
//        }
//        cell.textLabel?.textAlignment = .center
//        cell.accessibilityTraits = UIAccessibilityTraitButton
//        cell.selectionStyle = .none
//    }
//
//    override func onClick(_ navigationController: UINavigationController?) {
//        // Force editing to end for any focused text fields so they can finish up validation first.
//        navigationController?.view.endEditing(true)
//        if isEnabled?() ?? true {
//            onButtonClick(navigationController)
//        }
//    }
//}

class SettingsTableViewController: UITableViewController {

    fileprivate let Identifier = "CellIdentifier"
    fileprivate let SectionHeaderIdentifier = "SectionHeaderIdentifier"

    var settings = [SettingSection]()

    var hasSectionSeparatorLine = true

    /// Used to calculate cell heights.
    fileprivate lazy var dummyToggleCell: UITableViewCell = {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "dummyCell")
        cell.accessoryView = UISwitch()
        return cell
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.accessibilityIdentifier = "SettingsTableViewController.tableView"

        tableView.backgroundColor = UIColor.Defaults.lightBackgroudColor
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Identifier)
        tableView.register(SettingsTableSectionHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: SectionHeaderIdentifier)
        tableView.separatorColor = UIColor.Defaults.SeparatorColor

        tableView.tableFooterView = UIView(frame: CGRect(width: view.frame.width, height: 30))
        tableView.estimatedRowHeight = 44
        tableView.estimatedSectionHeaderHeight = 44

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        settings = generateSettings()

        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refresh()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    // override by different parent
    func generateSettings() -> [SettingSection] {
       return []
    }

    @objc fileprivate func refresh() {
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = settings[indexPath.section]
        if let setting = section[indexPath.row] {
            var cell: UITableViewCell!
            if let _ = setting.status {
                // Work around http://stackoverflow.com/a/9999821 and http://stackoverflow.com/a/25901083 by using a new cell.
                // I could not make any setNeedsLayout solution work in the case where we disconnect and then connect a new account.
                // Be aware that dequeing and then ignoring a cell appears to cause issues; only deque a cell if you're going to return it.
                cell = UITableViewCell(style: setting.style, reuseIdentifier: nil)
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: Identifier, for: indexPath)
            }
            setting.onConfigureCell(cell)
            return cell
        }
        return tableView.dequeueReusableCell(withIdentifier: Identifier, for: indexPath)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return settings.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = settings[section]
        return section.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderIdentifier) as! SettingsTableSectionHeaderFooterView
        let sectionSetting = settings[section]
        if let sectionTitle = sectionSetting.title?.string {
            headerView.titleLabel.text = sectionTitle.uppercased()
        }
        // Hide the top border for the top section to avoid having a double line at the top
        if section == 0 || !hasSectionSeparatorLine {
            headerView.showTopBorder = false
        } else {
            headerView.showTopBorder = true
        }

        return headerView
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionSetting = settings[section]
        guard let sectionFooter = sectionSetting.footerTitle?.string else {
            return nil
        }
        let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderIdentifier) as! SettingsTableSectionHeaderFooterView
        footerView.titleLabel.text = sectionFooter
        footerView.titleAlignment = .top
        footerView.showBottomBorder = false
        return footerView
    }

    // To hide a footer dynamically requires returning nil from viewForFooterInSection
    // and setting the height to zero.
    // However, we also want the height dynamically calculated, there is a magic constant
    // for that: `UITableViewAutomaticDimension`.
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let sectionSetting = settings[section]
        if let _ = sectionSetting.footerTitle?.string {
            return UITableViewAutomaticDimension
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = settings[indexPath.section]
        // Workaround for calculating the height of default UITableViewCell cells with a subtitle under
        // the title text label.
//        if let setting = section[indexPath.row], setting is BoolSetting && setting.status != nil {
//            return calculateStatusCellHeightForSetting(setting)
//        }
        if let setting = section[indexPath.row], let height = setting.cellHeight {
            return height
        }

        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = settings[indexPath.section]
        if let setting = section[indexPath.row], setting.enabled {
            setting.onClick(navigationController)
        }
    }

    fileprivate func calculateStatusCellHeightForSetting(_ setting: Setting) -> CGFloat {
        dummyToggleCell.layoutSubviews()

        let topBottomMargin: CGFloat = 10
        let width = dummyToggleCell.contentView.frame.width - 2 * dummyToggleCell.separatorInset.left

        return
            heightForLabel(dummyToggleCell.textLabel!, width: width, text: setting.title?.string) +
                heightForLabel(dummyToggleCell.detailTextLabel!, width: width, text: setting.status?.string) +
                2 * topBottomMargin
    }

    fileprivate func heightForLabel(_ label: UILabel, width: CGFloat, text: String?) -> CGFloat {
        guard let text = text else { return 0 }

        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let attrs = [NSAttributedStringKey.font: label.font as Any]
        let boundingRect = NSString(string: text).boundingRect(with: size,
                                                               options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        return boundingRect.height
    }
}