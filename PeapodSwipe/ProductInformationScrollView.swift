//
//  ProductInformationScrollView.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 3/8/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import Foundation
import UIKit

class ProductInformationScrollView: UIScrollView {
    var productFlags = [ProductFlagLabel]()
    let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.spacing = 8.0
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(10)
            make.width.equalToSuperview().offset(-20)
        }

    }

    func addProductFlag(labelText: String) {
        let productFlag = ProductFlagLabel()
        productFlag.text = labelText
        productFlag.snp.makeConstraints { (make) in
            make.height.equalTo(36)
        }
        stackView.addArrangedSubview(productFlag)
        self.productFlags.append(productFlag)

    }

    internal override func updateConstraints() {
        super.updateConstraints()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
