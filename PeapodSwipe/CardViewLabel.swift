//
//  CardViewLabel.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 11/25/17.
//  Copyright © 2017 Xinjiang Shao. All rights reserved.
//

import UIKit

class CardViewLabel: UILabel {
    static let size = CGSize(width: 120, height: 36)

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.textColor = .white
        self.font = UIFont.boldSystemFont(ofSize: 18)
        self.textAlignment = .center

        self.layer.cornerRadius = frame.height / 2
        self.layer.masksToBounds = true
        self.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
    }

    convenience init(origin: CGPoint, color: UIColor) {

        self.init(frame: CGRect(x: origin.x, y: origin.y, width: CardViewLabel.size.width, height: CardViewLabel.size.height))
        self.backgroundColor = color
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
