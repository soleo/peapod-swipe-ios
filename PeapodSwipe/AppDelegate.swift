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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        let window = UIWindow(frame: UIScreen.main.bounds)

        let authViewController = AuthViewController()
        window.rootViewController = authViewController
        window.makeKeyAndVisible()
        self.window = window

        return true
    }
    func application(_ application: UIApplication,
                     willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {

        var didHandleActivity = false
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL,
            let _ = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                return false
        }
        let authToken = url.lastPathComponent
        if url.pathComponents.contains("magic-link") {
            Alamofire.request(
                UserRouter.signInByMagicLink(authToken)
            )
            .validate()
            .responseJSON { response in

                // 1. Get beareer token get Authorization
                // 2. Store in UserDefaults for now, but ideally should be keychain
                // 3. Show cards

                if let bearerToken = response.response?.allHeaderFields["Authorization"] as? String {

                    let key: String = String(describing: UserSetting.self)

                    if var settings = UserDefaults.standard.df.fetch(forKey: key, type: UserSetting.self) {
                        settings.token = bearerToken
                        let email = settings.email
                        print (settings)

                        if let rootVC = self.window?.rootViewController {

                            Auth.auth().signIn(withEmail: email, password: "ppod9ppod9", completion: { (user, error) in
                                if error == nil {
                                    Analytics.logEvent("sign_in", parameters: [ "email": email ])
                                    let vc = CardViewController()
                                    rootVC.dismiss(animated: true, completion: {
                                        rootVC.present(vc, animated: true, completion: { () -> Void in
                                            restorationHandler([vc])
                                            didHandleActivity = true
                                            os_log("Magic Link Authentication", log: OSLog.default, type: .info)
                                        })
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
