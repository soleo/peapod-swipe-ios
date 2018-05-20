//
//  RecommendationRouter.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 3/3/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import Foundation
import Alamofire

public enum RecommendationRouter: URLRequestConvertible {
    static let baseURLPath = "https://admin-qa.peapod-swipe.com/swipe-api/v1/recommendation"

    case getProducts(Int)

    var method: HTTPMethod {
        switch self {
        case .getProducts:
            return .get
        }
    }
    public func asURLRequest() throws -> URLRequest {
        let parameters: [String: Any] = {
            switch self {
            case .getProducts(let recommendationSize):
                return [
                    "num": recommendationSize
                ]
            }
        }()

        let url = URL(string: RecommendationRouter.baseURLPath)!
        let key = String(describing: UserSetting.self)
        let setting = UserDefaults.standard.df.fetch(forKey: key, type: UserSetting.self)

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue(setting?.token, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = TimeInterval(10 * 1000)

        return try URLEncoding.default.encode(request, with: parameters)
    }

}
