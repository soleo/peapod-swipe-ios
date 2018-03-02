//
//  ProductImageSet.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 8/7/17.
//  Copyright © 2017 Xinjiang Shao. All rights reserved.
//

import Foundation


public struct ProductImage: Codable {
    var smallImageURL: String
    var mediumImageURL: String
    var largeImageURL: String
    var xlargeImageURL: String
    
    enum CodingKeys: String, CodingKey {
        case smallImageURL = "small"
        case mediumImageURL = "medium"
        case largeImageURL = "large"
        case xlargeImageURL = "xlarge"
    }
}
