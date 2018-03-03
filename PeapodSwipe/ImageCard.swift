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
import AlamofireImage


class ImageCard: CardView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, product: Product) {
        self.init(frame: frame)
        
        // large image url
        let url = URL(string: product.images.xlargeImageURL.trim())!
        let placeholderImage = UIImage(named: "placeholder")!
        
        let imageView = UIImageView()
        let imageSize = min(self.frame.width, self.frame.height)
        imageView.frame = CGRect(x: 12, y: 12, width: imageSize - 24, height: imageSize - 24)
        
        let filter = AspectScaledToFillSizeWithRoundedCornersFilter(
            size: imageView.frame.size,
            radius: 5
        )
        imageView.af_setImage(
            withURL: url,
            placeholderImage: placeholderImage,
            filter: filter,
            imageTransition: .crossDissolve(0.2)
        )
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = false
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(imageView)
        
        // product name text box
        let productName = UILabel()
        productName.textColor = UIColor.Defaults.primaryTextColor
        productName.text = product.name
        productName.textAlignment = .left
        productName.layer.masksToBounds = true
        productName.lineBreakMode = .byWordWrapping
        productName.numberOfLines = 0
        productName.frame = CGRect(x: 12, y: imageView.frame.maxY + 15, width: self.frame.width - 24, height: 48)
        self.addSubview(productName)
        
        let dislikeButton = UIButton()
        dislikeButton.setTitle("Dislike", for: .normal)
        dislikeButton.setTitleColor(UIColor.white, for: .normal)
        dislikeButton.setBackgroundColor(color: UIColor.Defaults.alizarin, forState: .normal)
        dislikeButton.frame = CGRect(x: 12, y: productName.frame.maxY + 50, width: 100, height: 30)
        self.addSubview(dislikeButton)
        
        
        let likeButton = UIButton()
        likeButton.setTitle("Like", for: .normal)
        likeButton.setTitleColor(UIColor.white, for: .normal)
        likeButton.setBackgroundColor(color: UIColor.Defaults.emerald, forState: .normal)
        likeButton.frame = CGRect(x: self.frame.width - 15 - 100, y: productName.frame.maxY + 50, width: 100, height: 30)
        self.addSubview(likeButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

