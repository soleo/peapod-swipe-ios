//
//  SearchViewController.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 3/3/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import UIKit
import Alamofire
import SnapKit

private struct SearchViewUX {
    static let SearchHeight: CGFloat = 58
    static let RowHeight: CGFloat = 58
    static let CancelButtonHeight: CGFloat = 60
    
}
class SearchViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = UIColor.Defaults.backgroundColor
        
        
        searchBar = UISearchBar()
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBar.backgroundColor = UIColor.clear
        searchBar.tintColor = UIColor.Defaults.primaryTextColor
        searchBar.placeholder = "Search Product ..."
        searchBar.delegate = self
        searchBar.isTranslucent = true
        // https://stackoverflow.com/questions/21191801/how-to-add-a-1-pixel-gray-border-around-a-uisearchbar-textfield/21192270
        for s in self.searchBar.subviews[0].subviews {
            if s is UITextField {
                s.layer.borderWidth = 1.0
                s.layer.cornerRadius = 10
                s.layer.borderColor = UIColor.Defaults.backgroundColor.cgColor
            }
        }
        
        view.addSubview(searchBar)
        
        tableView = UITableView()
        tableView.estimatedRowHeight = SearchViewUX.RowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        view.addSubview(tableView)
        view.addSubview(cancelButton)
        view.addSubview(loadingStateView)
        loadingStateView.isHidden = true
        
        
        dataSource = ProductSearchDataSource(tableView: tableView)
        tableView.dataSource = dataSource
        tableView.delegate = self
        
        searchBar.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalTo(self.view)
            make.height.equalTo(SearchViewUX.SearchHeight)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(self.cancelButton.snp.top)
        }
        cancelButton.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.view)
            make.top.equalTo(self.tableView.snp.bottom)
            make.bottom.equalTo(self.view)
            make.height.equalTo(SearchViewUX.CancelButtonHeight)
            
        }
        loadingStateView.snp.makeConstraints { (make) in
            make.edges.equalTo(tableView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.loadingStateView.searchBarHeight = searchBar.frame.height
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        // open item detail for that product
        
        let productDetailViewController = ProductDetailViewController()
        productDetailViewController.shouldShowNotifyButton = true
        productDetailViewController.productId = dataSource.products[indexPath.row].id
        self.present(productDetailViewController, animated: true) {
           // self.dismissViewController()
        }
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let input = searchBar.text?.trim()
        
        if let searchTerm = input {
            if performSearchForSearchTerm(searchTerm: searchTerm) {
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
    // MARK: - Search service
    private func performSearchForSearchTerm(searchTerm: String) -> Bool {
        let valid = searchTerm.count > 2
        if valid {
            loadingStateView.isHidden = false
            loadProductSearch(searchTerm: searchTerm)
        }
        return valid
    }
    
    private func showSearchResult(products: [Product]) {
        loadingStateView.isHidden = true
        dataSource.products = products
    }
    
    func loadProductSearch(searchTerm: String) {
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
                        PeapodProductSearchRouter.keywords(sessionResult.sessionId, searchTerm, "60606")
                        )
                        .validate()
                        .responseObject{ (response: DataResponse<ProductSearchResponseWithSessionId>) in
                            
                            if let productSearchResult = response.value {
                                self.showSearchResult(products: productSearchResult.response.products)
                            }
                    }
                }
                
        }
    }
    
    @objc func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private var dataSource: ProductSearchDataSource!
    private var searchBar: UISearchBar!
    private var tableView: UITableView!
    private let loadingStateView = LoadingStateView()
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.Defaults.backgroundColor
        button.addTarget(self, action: #selector(SearchViewController.dismissViewController), for: .touchUpInside)
        return button
    }()
}
