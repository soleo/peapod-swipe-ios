//
//  SearchRouter.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 3/3/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import Foundation
import Alamofire

public enum PeapodProductSearchRouter: URLRequestConvertible {

    static let baseURLPath = "https://www.peapod.com/api/v2.0"
    static let sessionTokenParam = ";jsession="

    case keywords(String, String, String)
    case details(String, Int)

    var method: HTTPMethod {
        switch self {
        case .keywords, .details:
            return .get
        }
    }

    var path: String {
        switch self {
        case .keywords(let sessionId, _, _):
            return "/products" + PeapodProductSearchRouter.sessionTokenParam + sessionId
        case .details(let sessionId, let productId):
            return "/products/\(productId)" + PeapodProductSearchRouter.sessionTokenParam + sessionId
        }
    }

    public func asURLRequest() throws -> URLRequest {
        let parameters: [String: Any] = {
            switch self {
            case .keywords(_, let keywords, let zip):
                return [
                    "keywords": keywords,
                    "zip": zip,
                    "flags": "false",
                    "rows": "120"
                ]

            case .details:
                return [
                    "serviceLocationId": "27346"
                ]
            default:
                return [:]
            }
        }()

        let url = URL(string: PeapodProductSearchRouter.baseURLPath)!
        var serviceConfig: NSDictionary?
        if let path = Bundle.main.path(forResource: "PeapodService-Info", ofType: "plist") {
            serviceConfig = NSDictionary(contentsOfFile: path)
        }

        let appId = serviceConfig?.object(forKey: "CLIENT_ID") as! String
        let appSecret = serviceConfig?.object(forKey: "CLIENT_SECRET") as! String
        let authString = String(format: "%@:%@", appId, appSecret)
        let base64AuthString = Data(authString.utf8).base64EncodedString()

        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.setValue("Basic "+base64AuthString, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = TimeInterval(10 * 1000)

        return try URLEncoding.default.encode(request, with: parameters)
    }

}
