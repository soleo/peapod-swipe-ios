//
//  StringExtension.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 3/2/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import Foundation
extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}
