//
//  UserSetting.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 5/19/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import Foundation
import Default

struct UserSetting: Codable, DefaultStorable {
    let email: String
    var token: String

    var isLoggedIn: Bool
    var hasTouredBefore: Bool?

    enum CodingKeys: String, CodingKey {
        case email
        case token

        case isLoggedIn
        case hasTouredBefore
    }
}
