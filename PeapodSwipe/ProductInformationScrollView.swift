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
    let productFlagStackView = UIStackView()
    let productNutritionStackView = UIStackView()
    var nuntritionFactCounter = 0

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(productFlagStackView)

        productFlagStackView.translatesAutoresizingMaskIntoConstraints = false
        productFlagStackView.axis = .horizontal
        productFlagStackView.alignment = .leading
        productFlagStackView.distribution = .fillProportionally
        productFlagStackView.spacing = 8.0

        productFlagStackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(10)
            make.width.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        self.addSubview(productNutritionStackView)

        productNutritionStackView.translatesAutoresizingMaskIntoConstraints = false
        productNutritionStackView.axis = .horizontal
        productNutritionStackView.alignment = .center
        productNutritionStackView.distribution = .fillEqually
        productNutritionStackView.spacing = 8.0

        productNutritionStackView.snp.makeConstraints { (make) in
            make.top.equalTo(self.productFlagStackView.snp.bottom)
            make.width.equalTo(self.productFlagStackView)
            make.left.right.equalTo(self.productFlagStackView)
        }
    }

    func addProductFlag(labelText: String) {
        let productFlag = ProductFlagLabel()
        productFlag.text = labelText
        productFlagStackView.addArrangedSubview(productFlag)
        productFlag.snp.makeConstraints { (make) in
            make.height.equalTo(36)
        }
        self.productFlags.append(productFlag)
    }

    func addNutritionLabel(calorieTotal: Float?, saturatedFatTotal: Float?, sodiumTotal: Float?, sugarTotal: Float?) {
        let calorieLabel = ProductNutritionLabel()
        if calorieTotal != nil {
            calorieLabel.text = "Calorie\r\n\(calorieTotal ?? 0)"
        } else {
            calorieLabel.text = "Calorie\r\n--"
        }

        let saturatedFatLabel = ProductNutritionLabel()
        if saturatedFatTotal != nil {
            saturatedFatLabel.text = "Sat Fat\r\n\(saturatedFatTotal ?? 0)g"
        } else {
            saturatedFatLabel.text = "Sat Fat\r\n--"
        }

        let sodiumLabel = ProductNutritionLabel()
        if sodiumTotal != nil {
            sodiumLabel.text = "Sodium\r\n\(sodiumTotal ?? 0)mg"

        } else {
            sodiumLabel.text = "Sodium\r\n--"
        }

        let sugarLabel = ProductNutritionLabel()
        if sugarTotal != nil {
            sugarLabel.text = "Sugar\r\n\(sugarTotal ?? 0)g"

        } else {
            sugarLabel.text = "Sugar\r\n--"
        }

        productNutritionStackView.addArrangedSubview(calorieLabel)
        productNutritionStackView.addArrangedSubview(saturatedFatLabel)
        productNutritionStackView.addArrangedSubview(sodiumLabel)
        productNutritionStackView.addArrangedSubview(sugarLabel)

        calorieLabel.snp.makeConstraints { (make) in
            make.height.equalTo(70)
        }

        saturatedFatLabel.snp.makeConstraints { (make) in
            make.height.equalTo(calorieLabel)
        }

        sodiumLabel.snp.makeConstraints { (make) in
            make.height.equalTo(calorieLabel)
        }

        sugarLabel.snp.makeConstraints { (make) in
            make.height.equalTo(calorieLabel)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
