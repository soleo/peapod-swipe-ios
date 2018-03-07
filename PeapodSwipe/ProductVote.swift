//
//  ProductVote.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 3/3/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import Foundation

public struct ProductVote: Codable, CustomStringConvertible {

    var id: Int
    var like: Bool

    enum CodingKeys: String, CodingKey {
        case id = "productId"
        case like
    }

    public var description: String {
        return "Vote: { productId: \(id), \r\n vote: \(like) }"
    }
}
