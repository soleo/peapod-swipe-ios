//
//  ImageCard.swift
//  peapod swipe
//
//  Created by Xinjiang Shao on 6/12/17.
//  Copyright © 2017 Xinjiang Shao. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class ImageCard: CardView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // image
        let imageView = UIImageView(image: UIImage(named: "Apple"))
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        
        imageView.frame = CGRect(x: 12, y: 12, width: self.frame.width - 24, height: self.frame.height - 103)
        self.addSubview(imageView)
        
//        let seperatorLine = UIView()
//        seperatorLine.backgroundColor = UIColor.Defaults.backgroundColor
//        self.addSubview(seperatorLine)
        
        // product name text box
        let productName = UILabel()
        productName.textColor = UIColor.Defaults.primaryTextColor
        productName.text = "Apples"
        productName.textAlignment = .center
        productName.layer.masksToBounds = true
        productName.frame = CGRect(x: 12, y: imageView.frame.maxY + 15, width: self.frame.width, height: 24)
        self.addSubview(productName)
        
//        seperatorLine.snp.makeConstraints { (make) in
//            make.bottom.equalTo(imageView);
//            make.width.equalTo(imageView.frame.width)
//            make.height.equalTo(1)
//        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

