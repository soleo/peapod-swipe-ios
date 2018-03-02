//
//  Product.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 6/19/17.
//  Copyright © 2017 Xinjiang Shao. All rights reserved.
//

import Foundation


struct Product: Codable {
    
    var id: Int
    var name: String
    var images: ProductImage
    
    enum CodingKeys: String, CodingKey {
        case id = "productId"
        case name
        case images
    }
}

