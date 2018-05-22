//
//  SearchRouter.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 3/3/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import Foundation
import Alamofire
import Default

public enum SearchRouter: URLRequestConvertible {

    static let baseURLPath = "https://admin-qa.peapod-swipe.com/swipe-api/v1"

    case keywords(String)

    var method: HTTPMethod {
        switch self {
        case .keywords:
            return .get
        }
    }

    var path: String {
        switch self {
        case .keywords:
            return "/product-search"
        }
    }

    public func asURLRequest() throws -> URLRequest {
        let parameters: [String: Any] = {
            switch self {
            case .keywords(let keywords):
                return [
                    "keywords": keywords,
                    "index": "0",
                    "size": "120"
                ]
            }
        }()

        let url = URL(string: SearchRouter.baseURLPath)!
        let key = String(describing: UserInfo.self)
        let setting = UserDefaults.standard.df.fetch(forKey: key, type: UserInfo.self)
        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.timeoutInterval = TimeInterval(10 * 1000)
        let args = ProcessInfo.processInfo.arguments

        if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") || args.contains("UI_TEST_MODE") {
            var serviceConfig: NSDictionary?
            if let path = Bundle.main.path(forResource: "PeapodService-Info", ofType: "plist") {
                serviceConfig = NSDictionary(contentsOfFile: path)
            }

            let token = serviceConfig?.object(forKey: "TEST_TOKEN") as! String
            request.setValue(token, forHTTPHeaderField: "Authorization")

        } else {
            request.setValue(setting?.token, forHTTPHeaderField: "Authorization")
        }

        return try URLEncoding.default.encode(request, with: parameters)
    }

}
