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
    static let NameLabelHeight: CGFloat = 40
    static let SideMargin: CGFloat = 12
    static let NavigationBarHeight: CGFloat = 50
    
}

class ProductDetailViewController: UIViewController {
    
    var product: Product!
    var productId: Int!
    var shouldShowNotifyButton: Bool!
    
    let nameLabel = UILabel()
    let imageView = UIImageView()
    let ratingLabel = UILabel()
    let detailsTextView = UITextView()
    let notifyAdminButton = UIButton()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidLoad() {
        let navigationBar = UINavigationBar()
        view.addSubview(navigationBar)
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.dismissViewController))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissViewController))
        let notifyButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.dismissViewController))
        
        let navigationItem = UINavigationItem(title: "Product Detail")
        navigationItem.rightBarButtonItem = cancelButton
        if shouldShowNotifyButton {
            navigationItem.leftBarButtonItem = notifyButton
        }else {
            navigationItem.leftBarButtonItem = doneButton
        }
        
        
        navigationBar.items = [navigationItem]
        
        loadProductDetailData(productId: productId)
        view.backgroundColor = UIColor.white
        
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = false
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.accessibilityIgnoresInvertColors = true
        
        view.addSubview(imageView)
        view.addSubview(nameLabel)
        view.addSubview(ratingLabel)
        view.addSubview(detailsTextView)
        
        navigationBar.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leadingMargin)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailingMargin)
            make.height.equalTo(ProductDetailViewUX.NavigationBarHeight)
        }
        
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom).offset(ProductDetailViewUX.NavigationBarHeight)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailingMargin)
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
            make.height.equalTo(ProductDetailViewUX.ProductImageHeight)
            
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.imageView.snp.bottom).offset(10)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailingMargin).offset(-ProductDetailViewUX.SideMargin)
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading).offset(ProductDetailViewUX.SideMargin)
            make.height.equalTo(ProductDetailViewUX.NameLabelHeight)
        }
        
        ratingLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.nameLabel.snp.bottom)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailingMargin).offset(-ProductDetailViewUX.SideMargin)
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading).offset(ProductDetailViewUX.SideMargin)
            make.height.equalTo(ProductDetailViewUX.NameLabelHeight)
        }
        
        detailsTextView.snp.makeConstraints { (make) in
            make.top.equalTo(self.ratingLabel.snp.bottom)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailingMargin).offset(-ProductDetailViewUX.SideMargin)
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading).offset(ProductDetailViewUX.SideMargin)
            make.bottom.equalTo(self.view)
        }
        
        
    }
    
    @objc func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
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
            .responseObject{ (response: DataResponse<SesssionResponse>) in
                
                if let sessionResult = response.value {
                    
                    Alamofire.request(
                        PeapodProductSearchRouter.details(sessionResult.sessionId, productId)
                        )
                        .validate()
                        .responseObject{ (response: DataResponse<ProductSearchResponseWithSessionId>) in
                            
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
            radius: 5
        )
        let url = URL(string: self.product.images.xlargeImageURL.trim())!
        let placeholderImage = UIImage(named: "placeholder")!
        imageView.af_setImage(
            withURL: url,
            placeholderImage: placeholderImage,
            filter: filter,
            imageTransition: .crossDissolve(0.2)
        )
        nameLabel.text = self.product.name
        ratingLabel.text = "Rating: \(self.product.rating)"
        detailsTextView.text = self.product.extendedInfo?.detail
    }
}
