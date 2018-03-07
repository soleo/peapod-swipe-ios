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
    static let baseURLPath = "https://swipe-api.akang.info/v1/recommendation"

    case getProducts(Int)

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
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.timeoutInterval = TimeInterval(10 * 1000)

        return try URLEncoding.default.encode(request, with: parameters)
    }

}
