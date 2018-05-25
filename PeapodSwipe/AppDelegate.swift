//
//  AppDelegate.swift
//  peapod swipe
//
//  Created by Xinjiang Shao on 6/12/17.
//  Copyright © 2017 Xinjiang Shao. All rights reserved.
//

import UIKit
import Firebase
import os.log
import Alamofire
import Default
import Instabug

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var mainNavigationController: UINavigationController?
    var rootViewController: UIViewController?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
        ) -> Bool {
        FirebaseApp.configure()

        var serviceConfig: NSDictionary?
        if let path = Bundle.main.path(forResource: "PeapodService-Info", ofType: "plist") {
            serviceConfig = NSDictionary(contentsOfFile: path)
        }

        if let token = serviceConfig?.object(forKey: "INSTABUG_TOKEN") {
            Instabug.start(withToken: token as! String, invocationEvent: .shake)
        }

        let window = UIWindow(frame: UIScreen.main.bounds)

        if Auth.auth().currentUser != nil {
            rootViewController = CardViewController()
        } else {
            //rootViewController = AuthViewController()
            rootViewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "AuthViewController") as UIViewController


        }
        self.mainNavigationController = UINavigationController(rootViewController: rootViewController!)

        self.mainNavigationController?.edgesForExtendedLayout = UIRectEdge(rawValue: 0)

        self.window!.rootViewController = rootViewController
        window.rootViewController = self.mainNavigationController
        window.makeKeyAndVisible()
        self.window = window

        return true
    }

    func application(
        _ application: UIApplication,
        willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]? = nil
    ) -> Bool {
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {

    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([Any]?) -> Void
        ) -> Bool {

        var didHandleActivity = false
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL,
            let _ = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                return false
        }
        let authToken = url.lastPathComponent
        if url.pathComponents.contains("magic-link") {
            Alamofire.request(
                AuthRouter.signInByMagicLink(authToken)
            )
            .validate()
            .responseJSON { response in

                // 1. Get beareer token get Authorization
                // 2. Store in UserDefaults for now, but ideally should be keychain
                // 3. Show cards

                if let bearerToken = response.response?.allHeaderFields["Authorization"] as? String {

                    let key: String = String(describing: UserInfo.self)

                    if let settings = UserDefaults.standard.df.fetch(forKey: key, type: UserInfo.self) {
                        let email = settings.email
                        let newSetting = UserInfo(
                            email: email,
                            token: bearerToken,
                            inviteCode: settings.inviteCode,
                            isLoggedIn: true,
                            skipIntro: true
                        )

                        UserDefaults.standard.df.store(newSetting, forKey: key)

                        if let rootVC = self.window?.rootViewController {

                            Auth.auth().signIn(withEmail: email, password: "ppod9ppod9", completion: { (_, error) in
                                if error == nil {
                                    Analytics.logEvent("sign_in", parameters: [ "email": email ])
                                    let mainViewController = CardViewController()
                                    let mainNavigationController = UINavigationController(rootViewController: mainViewController)
                                    Instabug.identifyUser(withEmail: email, name: email)
                                    rootVC.present(mainNavigationController, animated: true, completion: { () -> Void in
                                        restorationHandler([mainViewController])
                                        didHandleActivity = true
                                        os_log("Magic Link Authentication", log: OSLog.default, type: .info)
                                    })

                                } else {
                                    os_log("Failed To Login Via Magic Link", log: OSLog.default, type: .info)
                                }
                            })

                        }
                    }
                }
            }
        }

        return didHandleActivity
    }

}
