//
//  RecommendedProduct.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 3/3/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import Foundation
public struct RecommendedProduct: Codable, CustomStringConvertible {
    
    var id: Int
    var name: String
    var images: ProductImage
    
    
    enum CodingKeys: String, CodingKey {
        case id = "productId"
        case name
        case images
    }
    
    public var description: String {
        return "Recommended Product: { name: \(name), \r\n productId: \(id), \r\n images: \(images) }"
    }
}
