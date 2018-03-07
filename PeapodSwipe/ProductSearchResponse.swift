//
//  ProductSearchResponse.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 3/2/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import Foundation

struct ProductSearchResponse: Codable, CustomStringConvertible {
    let products: [Product]
    let keywords: String?

    enum CodingKeys: String, CodingKey {
        case products
        case keywords
    }
    var description: String {
        return "{ products: \(products), \r\n keywords: \(String(describing: keywords)) }"
    }
}

struct ProductSearchResponseWithSessionId: Codable, CustomStringConvertible {
    let sessionId: String
    let response: ProductSearchResponse

    enum CodingKeys: String, CodingKey {
        case sessionId
        case response
    }

    var description: String {
        return "ProductSearch: { SessionId: \(sessionId), \r\n response: \(response)}"
    }
}
