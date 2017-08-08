//
//  ProductImageSet.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 8/7/17.
//  Copyright © 2017 Xinjiang Shao. All rights reserved.
//

import Foundation
import Gloss

public struct ProductImage: Decodable {
    public let imageUrlSmall: String!
    public let imageUrlMedium: String!
    public let imageUrlLarge: String!
    public let imageUrlXLarge: String!
    
    
    public init?(json: JSON) {
        self.imageUrlSmall = "small" <~~ json
        self.imageUrlMedium = "medium" <~~ json
        self.imageUrlLarge = "large" <~~ json
        self.imageUrlXLarge = "xlarge" <~~ json
        
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "small" ~~> self.imageUrlSmall,
            "medium" ~~> self.imageUrlMedium,
            "large" ~~> self.imageUrlLarge,
            "xlarge" ~~> self.imageUrlXLarge,
            
        ])
    }
}
