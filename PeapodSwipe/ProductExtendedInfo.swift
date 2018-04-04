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
  

    enum CodingKeys: String, CodingKey {
        case brandText
        case detail
    }
    public var description: String {
        return """
            {
                brand: \(brandText ?? "Not Set"), \r\n
                detail: \(detail ?? "Not Set")
            }
        """
    }
}
