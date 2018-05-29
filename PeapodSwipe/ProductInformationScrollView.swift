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
    //let productFlagStackView = UIStackView()
    let productFlagGroupStackView = UIStackView()
    let productNutritionStackView = UIStackView()
    var nuntritionFactCounter = 0
    let maxProductFlagColumns = 2
    let productRowHeight = 40

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(productFlagGroupStackView)

        productFlagGroupStackView.translatesAutoresizingMaskIntoConstraints = false
        productFlagGroupStackView.axis = .vertical
        productFlagGroupStackView.alignment = .leading
        productFlagGroupStackView.distribution = .fillProportionally
        productFlagGroupStackView.spacing = 8.0

        productFlagGroupStackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(10)
            make.width.equalToSuperview().offset(-20)
        }

        self.addSubview(productNutritionStackView)

        productNutritionStackView.translatesAutoresizingMaskIntoConstraints = false
        productNutritionStackView.axis = .horizontal
        productNutritionStackView.alignment = .center
        productNutritionStackView.distribution = .fillEqually
        productNutritionStackView.spacing = 8.0

        productNutritionStackView.snp.makeConstraints { (make) in
            make.top.equalTo(self.productFlagGroupStackView.snp.bottom)
            .offset(self.productFlagGroupStackView.layoutMargins.bottom)
            make.width.equalTo(self.productFlagGroupStackView)
            make.left.right.equalTo(self.productFlagGroupStackView)
        }
    }

    func addProductFlags(labels: [String]) {
        var thisRow = [String]()
        var labelNum = 0
        var rowCount = 0
        for label in labels {
            thisRow.append(label)
            labelNum += 1
            //if row is full or its the last flag, build the row
            if (thisRow.count >= maxProductFlagColumns) || (labelNum == labels.count){
                productFlagGroupStackView.addArrangedSubview(buildProductFlagRow(labels: thisRow))
                thisRow = [] //clear array
                rowCount += 1
            }
        }
        productFlagGroupStackView.snp.makeConstraints { (make) in
            make.height.equalTo((productRowHeight * rowCount))
        }
    }
    func buildProductFlagRow(labels: [String]) -> UIStackView {
        let productFlagStackView = UIStackView()
        productFlagGroupStackView.addSubview(productFlagStackView)
        productFlagStackView.translatesAutoresizingMaskIntoConstraints = false
        productFlagStackView.axis = .horizontal
        productFlagStackView.distribution = .fillEqually
        productFlagStackView.spacing = 8.0
        productFlagStackView.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalTo(productRowHeight)
        }
        for label in labels {
            productFlagStackView.addArrangedSubview(addProductFlag(labelText: label))
        }
        return productFlagStackView
    }

    func addProductFlag(labelText: String) -> ProductFlagLabel {
        let productFlag = ProductFlagLabel()
        productFlag.text = labelText
        self.productFlags.append(productFlag)
        return productFlag
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
