//
//  SearchRouter.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 3/3/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import Foundation
import Alamofire

public enum ProductSearchRouter: URLRequestConvertible {

    static let baseURLPath = "https://admin-qa.peapod-swipe.com/swipe-api/v1"

    case keywords(String)
    case details(Int)

    var method: HTTPMethod {
        switch self {
        case .keywords, .details:
            return .get
        }
    }

    var path: String {
        switch self {
        case .keywords(_):
            return "/org-product-search"
        case .details(let productId):
            return "/product/\(productId)"
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

                case .details:
                    return [:]
                default:
                    return [:]
            }
        }()

        let url = URL(string: ProductSearchRouter.baseURLPath)!
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
