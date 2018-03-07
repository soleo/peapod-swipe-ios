//
//  UIColorExtension.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 11/25/17.
//  Copyright © 2017 Xinjiang Shao. All rights reserved.
//

import UIKit

extension UIColor {
    
    public convenience init(rgb: Int) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8)  / 255.0,
            blue: CGFloat((rgb & 0x0000FF) >> 0)  / 255.0,
            alpha: 1)
    }
    
    struct Defaults {
        static let Grey10 = UIColor(rgb: 0xf9f9fa)
        static let Grey30 = UIColor(rgb: 0xd7d7db)
        static let Grey40 = UIColor(rgb: 0xb1b1b3)
        static let Grey50 = UIColor(rgb: 0x737373)
        static let Grey60 = UIColor(rgb: 0x4a4a4f)
        static let Grey70 = UIColor(rgb: 0x38383d)
        static let Grey80 = UIColor(rgb: 0x272727) // Grey80 is actually #2a2a2e
        static let Grey90 = UIColor(rgb: 0x0c0c0d)
        
        //FlatColors http://flatuicolors.com/
        static let emerald   = UIColor(rgb: 0x2ecc71)
        static let alizarin  = UIColor(rgb: 0xe74c3c)
        static let midnightBlue = UIColor(rgb: 0x2c3e50)
        static let puppyGreen = UIColor(rgb: 0x5ea000)
        static let burgerYellow = UIColor(red:0.96, green:0.81, blue:0.46, alpha:1.0)
        static let pandaBlue = UIColor(rgb: 0x008bac)
        static let tomatoRed = UIColor(rgb: 0xe53e30)
        
        static let primaryColor = UIColor.Defaults.puppyGreen
        static let secondaryColor = UIColor.Defaults.tomatoRed
        static let backgroundColor = UIColor(rgb: 0x363636)
        static let primaryTextColor = UIColor.Defaults.Grey80
    }

}
