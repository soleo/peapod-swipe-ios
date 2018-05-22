//
//  UserRouter.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 5/20/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import Foundation

import Alamofire

public enum UserRouter: URLRequestConvertible {
    static let baseURLPath = "https://admin-qa.peapod-swipe.com/swipe-api/v1/user"

    case userInfo()

    var method: HTTPMethod {
        switch self {
        case .userInfo:
            return .get

        }
    }

    public func asURLRequest() throws -> URLRequest {

        let url = URL(string: ProductRouter.baseURLPath)!

        let key = String(describing: UserInfo.self)
        let setting = UserDefaults.standard.df.fetch(forKey: key, type: UserInfo.self)

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = TimeInterval(10 * 1000)

        let args = ProcessInfo.processInfo.arguments

        if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") || args.contains("UI_TEST_MODE") {
            var serviceConfig: NSDictionary?
            if let path = Bundle.main.path(forResource: "PeapodService-Info", ofType: "plist") {
                serviceConfig = NSDictionary(contentsOfFile: path)
            }

            if let token = serviceConfig?.object(forKey: "TEST_TOKEN") {
                request.setValue(token as? String, forHTTPHeaderField: "Authorization")
            }

        } else {
            request.setValue(setting?.token, forHTTPHeaderField: "Authorization")
        }

        return try JSONEncoding.default.encode(request, with: nil)
    }

}
