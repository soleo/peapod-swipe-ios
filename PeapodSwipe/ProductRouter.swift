//
//  ProductRouter.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 3/3/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import Foundation
import Alamofire

public enum ProductRouter: URLRequestConvertible {
    static let baseURLPath = "https://admin-qa.peapod-swipe.com/swipe-api/v1/product"

    case getVote(Int)
    case postVote(Int, Bool)
    case details(Int)

    var method: HTTPMethod {
        switch self {
        case .details:
            return .get
        case .getVote:
            return .get
        case .postVote:
            return .post
        }
    }

    var path: String {
        switch self {
        case .details(let productId):
            return "/\(productId)"
        case .getVote(let productId):
            return "/\(productId)/vote"
        case .postVote(let productId, _):
            return "/\(productId)/vote"
        }
    }

    public func asURLRequest() throws -> URLRequest {
        let parameters: [String: Any] = {
            switch self {
            case .postVote(_, let vote):
                return [
                    "likes": vote
                ]
            default:
                return [:]
            }
        }()
        let url = URL(string: ProductRouter.baseURLPath)!
        let key = String(describing: UserSetting.self)
        let setting = UserDefaults.standard.df.fetch(forKey: key, type: UserSetting.self)

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

        return try JSONEncoding.default.encode(request, with: parameters)
    }

}
