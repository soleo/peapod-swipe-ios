//
//  ProductFlagLabel.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 3/8/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import UIKit
import SnapKit

class ProductFlagLabel: UILabel {
    static let topInset: CGFloat = 5.0
    static let bottomInset: CGFloat = 5.0
    static let leftInset: CGFloat = 5.0
    static let rightInset: CGFloat = 5.0

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.textColor = UIColor.Defaults.Grey50
        self.font = UIFont.systemFont(ofSize: 18)
        self.textAlignment = .center

        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)

    }

    convenience init() {
        self.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.Defaults.Grey30
    }
    convenience init(backgroundColor: UIColor, textColor: UIColor) {
        self.init()
        self.backgroundColor = backgroundColor
        self.textColor = textColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(
            top: ProductFlagLabel.topInset,
            left: ProductFlagLabel.leftInset,
            bottom: ProductFlagLabel.bottomInset,
            right: ProductFlagLabel.rightInset
        )
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }

    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += ProductFlagLabel.topInset + ProductFlagLabel.bottomInset
            contentSize.width += ProductFlagLabel.leftInset + ProductFlagLabel.rightInset
            return contentSize
        }
    }
}
