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

struct ImageCardUX {
    static let titleLabelHeight: CGFloat = 48
    static let sideMargin: CGFloat = 12
    static let buttonHeight: CGFloat = 40
    static let buttonWidth: CGFloat = 100
}

class ImageCard: CardView {
    
    var likeButton = UIButton()
    var dislikeButton = UIButton()
    var imageView = UIImageView()
    var titleLabel = UILabel()
    let placeholderImage = UIImage(named: "placeholder")!
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
        let url = URL(string: imageURL.trim())!
        
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
        imageView.isUserInteractionEnabled = true
        self.addSubview(imageView)
       
        titleLabel.textColor = UIColor.Defaults.primaryTextColor
        titleLabel.text = name
        titleLabel.isAccessibilityElement = true;
        titleLabel.accessibilityLabel = name;
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.layer.masksToBounds = true
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        self.addSubview(titleLabel)
        
        dislikeButton.setTitle("Dislike", for: .normal)
        dislikeButton.setTitleColor(UIColor.white, for: .normal)
        dislikeButton.setBackgroundColor(color: UIColor.Defaults.tomatoRed, forState: .normal)
        dislikeButton.isAccessibilityElement = true
        dislikeButton.accessibilityTraits = UIAccessibilityTraitButton
        dislikeButton.accessibilityLabel = "Dislike"
        dislikeButton.layer.cornerRadius = 5
        dislikeButton.layer.masksToBounds = true
        self.addSubview(dislikeButton)
        
        likeButton.setTitle("Like", for: .normal)
        likeButton.setTitleColor(UIColor.white, for: .normal)
        likeButton.setBackgroundColor(color: UIColor.Defaults.puppyGreen, forState: .normal)
        likeButton.isAccessibilityElement = true
        likeButton.accessibilityTraits = UIAccessibilityTraitButton
        likeButton.accessibilityLabel = "Like"
        likeButton.layer.cornerRadius = 5
        likeButton.layer.masksToBounds = true
        self.addSubview(likeButton)
        
        imageView.accessibilityElementsHidden = true
        dislikeButton.accessibilityElementsHidden = true
        likeButton.accessibilityElementsHidden = true
        titleLabel.accessibilityElementsHidden = true
        
        imageView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.size.equalTo(self.snp.width)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom)
            make.left.equalToSuperview().offset(ImageCardUX.sideMargin)
            make.right.equalToSuperview().offset(-ImageCardUX.sideMargin)
            make.height.greaterThanOrEqualTo(ImageCardUX.titleLabelHeight)
        }
        
        dislikeButton.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.equalToSuperview().offset(ImageCardUX.sideMargin)
            make.bottom.equalToSuperview().offset(-ImageCardUX.sideMargin)
            make.height.equalTo(ImageCardUX.buttonHeight)
            make.width.equalTo(ImageCardUX.buttonWidth)
        }
        
        likeButton.snp.makeConstraints { (make) in
            make.top.greaterThanOrEqualTo(titleLabel.snp.bottom)
            make.right.equalToSuperview().offset(-ImageCardUX.sideMargin)
            make.bottom.equalToSuperview().offset(-ImageCardUX.sideMargin)
            make.height.equalTo(ImageCardUX.buttonHeight)
            make.width.equalTo(ImageCardUX.buttonWidth)
        }
    }
    
    public func removeAccessibilityHidden() {
        imageView.accessibilityElementsHidden = false
        dislikeButton.accessibilityElementsHidden = false
        likeButton.accessibilityElementsHidden = false
        titleLabel.accessibilityElementsHidden = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

