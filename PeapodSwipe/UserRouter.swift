//
//  UserRouter.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 4/25/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import Foundation
import Alamofire

public enum UserRouter: URLRequestConvertible {
    static let baseURLPath = "https://admin-qa.peapod-swipe.com/swipe-api/v1"
    
    case register(String, String)
    case requestForMagicLink(String)
    case signInByMagicLink(String)
    
    var method: HTTPMethod {
        switch self {
        case .register, .requestForMagicLink, .signInByMagicLink:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .register(_, _):
            return "/employee/register"
        case .requestForMagicLink(_):
            return "/magic-link/request"
        case .signInByMagicLink(let token):
            return "/magic-link/auth/\(token)"
        }
    }
    
    public func asURLRequest() throws -> URLRequest {
        let parameters: [String: Any] = {
            switch self {
            case .register(let email, let inviteCode):
                return [
                    "email": email,
                    "inviteCode": inviteCode,
                    "name": "",
                    "nickname": ""
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
