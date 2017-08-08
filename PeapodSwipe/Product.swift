//
//  Product.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 6/19/17.
//  Copyright © 2017 Xinjiang Shao. All rights reserved.
//

import Foundation
import Gloss

public struct Product: Decodable {
    
    public let id: String?
    public let name: String?
    public let images: ProductImage?

    public init?(json: JSON) {
        
        self.id = "productId" <~~ json
        self.name = "name" <~~ json
        self.images = "images" <~~ json
    }
    
}



