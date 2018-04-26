//
//  VoteRouter.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 3/3/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import Foundation
import Alamofire

public enum VoteRouter: URLRequestConvertible {
    static let baseURLPath = "https://admin-qa.peapod-swipe.com/swipe-api/v1/product"

    case getVote(Int)
    case postVote(Int, Bool)

    var method: HTTPMethod {
        switch self {
        case .getVote:
            return .get
        case .postVote:
            return .post
        }
    }

    var path: String {
        switch self {
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
                    "like": vote
                ]
            default:
                return [:]
            }
        }()
        let url = URL(string: VoteRouter.baseURLPath)!
        var serviceConfig: NSDictionary?
        if let path = Bundle.main.path(forResource: "PeapodService-Info", ofType: "plist") {
            serviceConfig = NSDictionary(contentsOfFile: path)
        }
        
        let token = serviceConfig?.object(forKey: "BEARER_TOKEN") as! String
        
        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.setValue("Bearer "+token, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = TimeInterval(10 * 1000)

        return try JSONEncoding.default.encode(request, with: parameters)
    }

}
