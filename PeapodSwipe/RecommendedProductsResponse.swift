//
//  RecommendedProductsResponse.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 3/3/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import Foundation

struct RecommendedProductsResponse: Codable, CustomStringConvertible {
    let products: [Product]

    enum CodingKeys: String, CodingKey {
        case products
    }

    var description: String {
        return "{ products: \(products) }"
    }
}
