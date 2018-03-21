//
//  Product.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 6/19/17.
//  Copyright © 2017 Xinjiang Shao. All rights reserved.
//

import Foundation

public struct Product: Codable, CustomStringConvertible {

    var id: Int
    var name: String
    var images: ProductImage

    var prodSize: String
    var unitPrice: Float
    var unitMeasure: String?
    var price: Float?
    var regularPrice: Float?

    var rootCatId: Int?
    var rootCatSeq: Int?
    var rootCatName: String?
    var upc: String?
    var hasSubstitute: Bool?
    var substituteId: Int?
    var rating: Float?
    var ratingReviewsSuppressed: Bool?
    var marketSpecificReviews: Bool?
    var reviewId: String?
    var extendedInfo: ProductExtendedInfo?
    var productFlags: ProductFlagCollection?
    var nutrition: ProductNutrition?

    enum CodingKeys: String, CodingKey {
        case id = "prodId"
        case name
        case images = "image"
        case prodSize = "size"
        case unitPrice
        case unitMeasure
        case price
        case regularPrice
        case rootCatId
        case rootCatSeq
        case rootCatName
        case upc
        case hasSubstitute
        case substituteId
        case rating
        case ratingReviewsSuppressed
        case marketSpecificReviews
        case reviewId
        case extendedInfo
        case productFlags
        case nutrition
    }

    public var description: String {
        return "Product: { name: \(name), \r\n productId: \(id), \r\n images: \(images), \r\n size: \(prodSize), \r\n unit price: \(unitPrice), \r\n unit measure: \(unitMeasure), \r\n rating: \(rating)}"
    }
}
