//
//  SessionResponse.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 3/3/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import Foundation

struct SesssionResponse: Codable, CustomStringConvertible {
    let sessionId: String

    enum CodingKeys: String, CodingKey {
        case sessionId

    }
    var description: String {
        return "{ sessionId: \(sessionId) }"
    }
}
