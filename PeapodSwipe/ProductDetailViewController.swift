//
//  ProductDetailViewController.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 3/4/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Alamofire
import AlamofireImage

struct ProductDetailViewUX {
    static let ProductImageHeight: CGFloat = 300
    static let titleLabelHeight: CGFloat = 32 * 2
    static let NameLabelHeight: CGFloat = 50
    static let SideMargin: CGFloat = 12
    static let NavigationBarHeight: CGFloat = 50

}

class ProductDetailViewController: UIViewController {

    var product: Product!
    var productId: Int!
    var shouldShowNotifyButton: Bool!

    let titleLabel = UILabel()
    let imageView = UIImageView()
    let ratingLabel = UILabel()
    let detailsTextView = UITextView()
    let productInformationScrollView = ProductInformationScrollView()
    let likeButton = UIButton()
    let placeholderImage = UIImage(named: "placeholder")
    let loadingStateView = LoadingStateView()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingStateView.isHidden = false
        loadProductDetailData(productId: productId)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }

    override func viewDidLoad() {
        view.backgroundColor = UIColor.white

        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = false
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 0
        imageView.layer.masksToBounds = true
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.accessibilityIgnoresInvertColors = true

        loadingStateView.isHidden = true

        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.layer.masksToBounds = true
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0

        likeButton.setTitle("I Love this!", for: .normal)
        likeButton.setTitleColor(UIColor.white, for: .normal)
        likeButton.backgroundColor = UIColor.Defaults.waterBlue
        likeButton.layer.cornerRadius = 5
        likeButton.layer.masksToBounds = true
        likeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProductDetailViewController.likeProductFromItemDetail)))
        if shouldShowNotifyButton {
            likeButton.isHidden = false
        } else {
            likeButton.isHidden = true
        }

        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProductDetailViewController.dismissViewController)))
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(ProductDetailViewController.dismissViewController))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        imageView.addGestureRecognizer(swipeDown)

        view.addSubview(loadingStateView)
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(likeButton)
        view.addSubview(productInformationScrollView)

        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(self.view.snp.width)
        }

        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.imageView.snp.bottom).offset(10)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailingMargin).offset(-ProductDetailViewUX.SideMargin)
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading).offset(ProductDetailViewUX.SideMargin)
            make.height.greaterThanOrEqualTo(ProductDetailViewUX.titleLabelHeight)
        }

        likeButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(ProductDetailViewUX.SideMargin)
            make.left.right.equalTo(self.titleLabel)
            make.height.equalTo(ProductDetailViewUX.NameLabelHeight)
        }

        productInformationScrollView.snp.makeConstraints { (make) in
            if shouldShowNotifyButton {
                make.top.equalTo(self.likeButton.snp.bottom)
            } else {
                make.top.equalTo(self.titleLabel.snp.bottom)
            }

            make.left.right.bottom.equalTo(self.view)
        }

        loadingStateView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }

    }

    @objc func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func likeProductFromItemDetail() {
        Alamofire.request(
            VoteRouter.postVote(self.productId, true)
            )
            .validate()
            .responseString { (response: DataResponse<String>) in
                print("Love \(self.productId)")
                if let voteResult = response.value {
                    print(voteResult)
                    self.dismiss(animated: true, completion: nil)
                }
        }
    }

    func loadProductDetailData(productId: Int) {
        var headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        var serviceConfig: NSDictionary?
        if let path = Bundle.main.path(forResource: "PeapodService-Info", ofType: "plist") {
            serviceConfig = NSDictionary(contentsOfFile: path)
        }

        let appId = serviceConfig?.object(forKey: "CLIENT_ID") as! String
        let appSecret = serviceConfig?.object(forKey: "CLIENT_SECRET") as! String

        if let authorizationHeader = Request.authorizationHeader(user: appId, password: appSecret) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }

        Alamofire.request("https://www.peapod.com/api/v2.0/sessionid", method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .responseObject { (response: DataResponse<SesssionResponse>) in

                if let sessionResult = response.value {

                    Alamofire.request(
                        PeapodProductSearchRouter.details(sessionResult.sessionId, productId)
                        )
                        .validate()
                        .responseObject { (response: DataResponse<ProductSearchResponseWithSessionId>) in
                            print(response.value)
                            if let productSearchResult = response.value {
                                
                                self.showItemDetail(product: productSearchResult.response.products[0])
                            }
                    }
                }

        }
    }

    func showItemDetail(product: Product) {
        self.product = product
        let filter = AspectScaledToFillSizeWithRoundedCornersFilter(
            size: imageView.frame.size,
            radius: 0
        )
        let url = URL(string: self.product.images.xlargeImageURL.trim())!

        imageView.af_setImage(
            withURL: url,
            placeholderImage: placeholderImage,
            filter: filter,
            imageTransition: .crossDissolve(0.2)
        )
        imageView.isAccessibilityElement = true
        imageView.accessibilityLabel = self.product.name
        imageView.accessibilityTraits = UIAccessibilityTraitImage

        titleLabel.text = self.product.name
        loadingStateView.isHidden = true

        addProductFlags()
        
        //addProductFakeFlags()
    }
    func addProductFakeFlags() {
        productInformationScrollView.addProductFlag(labelText: "Dairy-free")
        productInformationScrollView.addProductFlag(labelText: "Dairy-free")
        productInformationScrollView.addProductFlag(labelText: "Dairy-free")
        productInformationScrollView.addProductFlag(labelText: "Dairy-free")
        productInformationScrollView.addProductFlag(labelText: "Dairy-free")
    }
    func addProductFlags() {
        if (self.product.productFlags?.dairy?.flag)! {
            productInformationScrollView.addProductFlag(labelText: "Dairy-free")
        }

        if (self.product.productFlags?.gluten?.flag)! {
            productInformationScrollView.addProductFlag(labelText: "Gluten-free")
        }

        if (self.product.productFlags?.peanut?.flag)! {
            productInformationScrollView.addProductFlag(labelText: "Peanut-free")
        }

        if (self.product.productFlags?.egg?.flag)! {
            productInformationScrollView.addProductFlag(labelText: "Egg-free")
        }

        if (self.product.productFlags?.privateLabel?.flag)! {
            productInformationScrollView.addProductFlag(labelText: "Store Brand")
        }

        if (self.product.productFlags?.organic?.flag)! {
            productInformationScrollView.addProductFlag(labelText: "Organic")
        }

        if (self.product.productFlags?.kosher)! {
            productInformationScrollView.addProductFlag(labelText: "Kosher")
        }
    }
}
