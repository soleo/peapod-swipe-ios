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
    
    var likeButton: UIButton!
    var dislikeButton: UIButton!
    var imageView: UIImageView!
    var productName: UILabel!
    
    var productId: Int!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, product: Product) {
        self.init(frame: frame)
        
        self.productId = product.id
        setUpLayout(imageURL: product.images.xlargeImageURL, name: product.name)
        
    }
    
    convenience init(frame: CGRect, product: RecommendedProduct) {
        self.init(frame: frame)
        
        self.productId = product.id
        setUpLayout(imageURL: product.images.xlargeImageURL, name: product.name)
    }
    
    private func setUpLayout(imageURL:String, name: String) {
        // large image url
        let url = URL(string: imageURL.trim())!
        let placeholderImage = UIImage(named: "placeholder")!
        
        imageView = UIImageView()
        let imageSize = min(self.frame.width, self.frame.height)
        imageView.frame = CGRect(x: 12, y: 12, width: imageSize - 24, height: imageSize - 24)
        imageView.isAccessibilityElement = true
        imageView.accessibilityTraits = UIAccessibilityTraitImage
        imageView.accessibilityLabel = name
        
        
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
        imageView.accessibilityIgnoresInvertColors = true
        self.addSubview(imageView)
        
        // product name text box
        productName = UILabel()
        productName.textColor = UIColor.Defaults.primaryTextColor
        productName.text = name
        productName.isAccessibilityElement = true;
        productName.accessibilityLabel = name;
        productName.textAlignment = .left
        productName.layer.masksToBounds = true
        productName.lineBreakMode = .byWordWrapping
        productName.numberOfLines = 0
        productName.frame = CGRect(x: 12, y: imageView.frame.maxY + 15, width: self.frame.width - 24, height: 48)
        self.addSubview(productName)
        
        dislikeButton = UIButton()
        dislikeButton.setTitle("Dislike", for: .normal)
        dislikeButton.setTitleColor(UIColor.white, for: .normal)
        dislikeButton.setBackgroundColor(color: UIColor.Defaults.alizarin, forState: .normal)
        dislikeButton.frame = CGRect(x: 12, y: self.frame.height - 30 - 12 , width: 100, height: 30)
        dislikeButton.isAccessibilityElement = true
        dislikeButton.accessibilityTraits = UIAccessibilityTraitButton
        dislikeButton.accessibilityLabel = "Dislike"
        self.addSubview(dislikeButton)
        
        
        likeButton = UIButton()
        likeButton.setTitle("Like", for: .normal)
        likeButton.setTitleColor(UIColor.white, for: .normal)
        likeButton.setBackgroundColor(color: UIColor.Defaults.emerald, forState: .normal)
        likeButton.frame = CGRect(x: self.frame.width - 15 - 100, y: self.frame.height - 30 - 12, width: 100, height: 30)
        likeButton.isAccessibilityElement = true
        likeButton.accessibilityTraits = UIAccessibilityTraitButton
        likeButton.accessibilityLabel = "Like"
        self.addSubview(likeButton)
        
        imageView.accessibilityElementsHidden = true
        dislikeButton.accessibilityElementsHidden = true
        likeButton.accessibilityElementsHidden = true
        productName.accessibilityElementsHidden = true
    }
    
    public func removeAccessibilityHidden() {
        imageView.accessibilityElementsHidden = false
        dislikeButton.accessibilityElementsHidden = false
        likeButton.accessibilityElementsHidden = false
        productName.accessibilityElementsHidden = false
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

