//
//  JsessionHandler.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 3/2/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import Foundation
import Alamofire

class PeapodJsessionHandler: RequestAdapter, RequestRetrier {
    private typealias RefreshCompletion = (_ succeeded: Bool, _ refreshedJesssionId: String?) -> Void
    
    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        //configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        //configuration.httpShouldSetCookies = true
        configuration.httpAdditionalHeaders = [
            "Content-Type": "application/json"
        ]
        return SessionManager(configuration: configuration)
    }()
    
    private let lock = NSLock()
    

    private var baseURLString: String
    private var basicAuthToken: String
    private var jsessionId: String
    
    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    
    // MARK: - Initialization
    
    public init() {
        var serviceConfig: NSDictionary?
        if let path = Bundle.main.path(forResource: "PeapodService-Info", ofType: "plist") {
            serviceConfig = NSDictionary(contentsOfFile: path)
        }
        
        let appId = serviceConfig?.object(forKey: "CLIENT_ID") as! String
        let appSecret = serviceConfig?.object(forKey: "CLIENT_SECRET") as! String
        let authString = String(format: "%@:%@", appId, appSecret)
        let base64AuthString = Data(authString.utf8).base64EncodedString()
        self.basicAuthToken = "Basic " + base64AuthString
        self.baseURLString = "https://wwww.peapod.com"
        self.jsessionId = ""
        
    }
    
    // MARK: - RequestAdapter
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix(baseURLString) {
            var urlRequest = urlRequest
             // Add jsession to URL all the time
            urlRequest.url?.appendPathComponent(";jsessionId="+self.jsessionId)
            urlRequest.setValue(self.basicAuthToken, forHTTPHeaderField: "Authorization")
            return urlRequest
        }
        
        return urlRequest
    }
    
    // MARK: - RequestRetrier
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        lock.lock() ; defer { lock.unlock() }
        
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 403 {
            requestsToRetry.append(completion)
            
            if !isRefreshing {
                refreshJsessionId { [weak self] succeeded, jsessionId in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }
                    
                    if let jsessionId = jsessionId {
                        strongSelf.jsessionId = jsessionId
                        
                    }
                    
                    strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
                    strongSelf.requestsToRetry.removeAll()
                }
            }
        } else {
            completion(false, 0.0)
        }
    }

    // MARK: - Private - Refresh JsesssionId
    
    private func refreshJsessionId(completion: @escaping RefreshCompletion) {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        
        let getSessionIdEndpoint = "\(baseURLString)/api/v2.0/sessionid"
        
        sessionManager.request(getSessionIdEndpoint,
                               encoding: JSONEncoding.default)
            .responseJSON { [weak self] response in
                guard let strongSelf = self else { return }
                
                if
                    let json = response.result.value as? [String: Any],
                    let jsessionId = json["sessionId"] as? String
    
                {
                    completion(true, jsessionId)
                } else {
                    completion(false, nil)
                }
                
                strongSelf.isRefreshing = false
        }
    }
}
