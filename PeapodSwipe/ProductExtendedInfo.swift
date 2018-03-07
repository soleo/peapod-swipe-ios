//
//  ProductExtendedInfo.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 3/4/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import Foundation

public struct ProductExtendedInfo: Codable, CustomStringConvertible {
    let brandText: String?
    let detail: String?
   // let active: Bool

    enum CodingKeys: String, CodingKey {
        case brandText
        case detail
       // case active
    }
    public var description: String {
        return """
            {
                brand: \(String(describing: brandText)), \r\n
                detail: \(String(describing: detail))
            }
        """
    }
}
