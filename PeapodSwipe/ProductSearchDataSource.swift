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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "SearchCell"),
        product = products[indexPath.row]
        cell.textLabel!.text = product.name
        cell.textLabel!.isAccessibilityElement = true
        cell.textLabel!.accessibilityLabel = product.name
        cell.textLabel!.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.regular)
        cell.textLabel!.numberOfLines = 3
        if let prodSize = product.prodSize {
            cell.detailTextLabel!.text = "Size: \(prodSize)"
        }

        let url = URL(string: product.images.mediumImageURL.trim())!
        cell.imageView?.isAccessibilityElement = true
        cell.imageView?.accessibilityTraits = UIAccessibilityTraitImage
        cell.imageView?.accessibilityLabel = product.name

        let filter = AspectScaledToFillSizeWithRoundedCornersFilter(
            size: (cell.imageView?.frame.size)!,
            radius: 2
        )

        cell.imageView?.af_setImage(
            withURL: url,
            placeholderImage: placeholderImage,
            filter: filter,
            imageTransition: .crossDissolve(0.2)
        )

        let itemSize = CGSize.init(width: 50, height: 50)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale)
        let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
        cell.imageView?.image!.draw(in: imageRect)
        cell.imageView?.image! = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        cell.imageView?.accessibilityIgnoresInvertColors = true

        cell.accessibilityTraits = UIAccessibilityTraitButton
        cell.indentationWidth = 0
        cell.layoutMargins = .zero
        // So that the separator line goes all the way to the left edge.
        cell.separatorInset = .zero
        return cell
    }

    private var tableView: UITableView!
    private let emptySearchResultView = EmptySearchResultView()
    private let placeholderImage = UIImage(named: "placeholder")
}
