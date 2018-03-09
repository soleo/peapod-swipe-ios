//
//  ProductRichFlag.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 3/7/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import Foundation

public struct ProductRichFlag: Codable {
    let flag: Bool?
    let imageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case flag
        case imageURL
    }
}
