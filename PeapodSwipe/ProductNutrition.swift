//
//  ProductNutrition.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 3/20/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import Foundation

public struct ProductNutrition: Codable {
    let nutritionShow: Bool?
    let totalCaloriesShow: Bool?
    let totalCalories: Float?
    let sugarShow: Bool?
    let sugar: Float?
    let saturatedFatShow: Bool?
    let saturatedFat: Float?
    let sodium: Float?
    let sodiumShow: Bool?

    enum CodingKeys: String, CodingKey {
        case nutritionShow
        case totalCaloriesShow
        case totalCalories
        case sugar
        case sugarShow
        case saturatedFatShow
        case saturatedFat
        case sodiumShow
        case sodium
    }
}
