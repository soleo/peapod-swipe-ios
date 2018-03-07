//
//  ProductImageSet.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 8/7/17.
//  Copyright © 2017 Xinjiang Shao. All rights reserved.
//

import Foundation

public struct ProductImage: Codable, CustomStringConvertible {
    let smallImageURL: String
    let mediumImageURL: String
    let largeImageURL: String
    let xlargeImageURL: String

    enum CodingKeys: String, CodingKey {
        case smallImageURL = "small"
        case mediumImageURL = "medium"
        case largeImageURL = "large"
        case xlargeImageURL = "xlarge"
    }

    public var description: String {
        return "{ large: \(largeImageURL) }"
    }
}
