//
//  ProductSearchDataSource.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 3/3/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import UIKit
import AlamofireImage

class ProductSearchDataSource: NSObject, UITableViewDataSource {
    
    init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    var products: [Product] = [] { didSet { tableView.reloadData() }}
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let searchResultTotal = products.count
        if searchResultTotal == 0 {
            tableView.backgroundView = emptySearchResultView
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
        return searchResultTotal
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier:"Cell"),
        product = products[indexPath.row]
        cell.textLabel!.text = product.name
        
        let url = URL(string: product.images.mediumImageURL.trim())!
        cell.imageView?.isAccessibilityElement = true
        cell.imageView?.accessibilityTraits = UIAccessibilityTraitImage
        cell.imageView?.accessibilityLabel = product.name
        let filter = AspectScaledToFillSizeWithRoundedCornersFilter(
            size: (cell.imageView?.frame.size)!,
            radius: 5
        )
        cell.imageView?.af_setImage(
            withURL: url,
            placeholderImage: placeholderImage,
            filter: filter,
            imageTransition: .crossDissolve(0.2)
        )
        
        cell.imageView?.contentMode = .scaleAspectFit
        cell.imageView?.clipsToBounds = false
        cell.imageView?.backgroundColor = .white
        cell.imageView?.layer.cornerRadius = 5
        cell.imageView?.layer.masksToBounds = true
        cell.imageView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cell.imageView?.accessibilityIgnoresInvertColors = true
        
        return cell
    }
    
    private var tableView:  UITableView!
    private let emptySearchResultView = EmptySearchResultView()
    private let placeholderImage = UIImage(named: "placeholder")
}
