//
//  UserSetting.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 5/19/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import Foundation
import Default

struct UserInfo: Codable, DefaultStorable {
    let email: String
    let token: String
    let inviteCode: String

    var isLoggedIn: Bool
    var skipIntro: Bool?

    enum CodingKeys: String, CodingKey {
        case email
        case token
        case inviteCode
        case isLoggedIn
        case skipIntro
    }
}
