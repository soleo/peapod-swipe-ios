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
            case .keywords(_):
                return "/product-search"
        }
    }

    public func asURLRequest() throws -> URLRequest {
        let parameters: [String: Any] = {
            switch self {
                case .keywords(let keywords):
                    return [
                        "keywords": keywords,
                        "index": 0,
                        "size": "120"
                    ]

                default:
                    return [:]
            }
        }()

        let url = URL(string: SearchRouter.baseURLPath)!
        let key = String(describing: UserSetting.self)
        let setting = UserDefaults.standard.df.fetch(forKey: key, type: UserSetting.self)
        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.setValue(setting?.token, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = TimeInterval(10 * 1000)

        return try URLEncoding.default.encode(request, with: parameters)
    }

}
