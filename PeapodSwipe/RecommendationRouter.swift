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
            default:
                return [:]
            }
        }()

        let url = URL(string: RecommendationRouter.baseURLPath)!
        var serviceConfig: NSDictionary?
        if let path = Bundle.main.path(forResource: "PeapodService-Info", ofType: "plist") {
            serviceConfig = NSDictionary(contentsOfFile: path)
        }

        let token = serviceConfig?.object(forKey: "BEARER_TOKEN") as! String

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("Bearer "+token, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = TimeInterval(10 * 1000)

        return try URLEncoding.default.encode(request, with: parameters)
    }

}
