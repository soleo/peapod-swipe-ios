//
//  ProductInformationScrollView.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 3/8/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import Foundation
import UIKit

class ProductInformationScrollView: UIScrollView, UIScrollViewDelegate {
    var productFlags = [ProductFlagLabel]()
    let productFlagGroupStackView = UIStackView()
    let productNutritionStackView = UIStackView()
    var nuntritionFactCounter = 0
    let maxProductFlagColumns = 2
    let productRowHeight = 40
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scrolling")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.delegate = self
        self.addSubview(productFlagGroupStackView)

        productFlagGroupStackView.translatesAutoresizingMaskIntoConstraints = false
        productFlagGroupStackView.axis = .vertical
        productFlagGroupStackView.alignment = .leading
        productFlagGroupStackView.distribution = .fillProportionally
        productFlagGroupStackView.spacing = 8.0
        productFlagGroupStackView.layoutMargins.bottom = 8.0

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
            if (thisRow.count >= maxProductFlagColumns) || (labelNum == labels.count) {
                productFlagGroupStackView.addArrangedSubview(buildProductFlagRow(labels: thisRow))
                thisRow = [] //clear array
                rowCount += 1
            }
        }
        productFlagGroupStackView.snp.makeConstraints { (make) in
            //The 8 is to force the bottom margin.
            make.height.equalTo((productRowHeight * rowCount) + 8 )
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
            make.height.equalTo(productRowHeight).priority(900)
        }
        for label in labels {
            productFlagStackView.addArrangedSubview(addProductFlag(labelText: label))
        }
        return productFlagStackView
    }

    func addProductFlag(labelText: String) -> ProductFlagLabel {
        let productFlag = ProductFlagLabel(backgroundColor: UIColor.Defaults.peaGreen, textColor: UIColor.white)
        productFlag.alpha = 0.60
        productFlag.text = labelText
        self.productFlags.append(productFlag)
        return productFlag
    }

    func createNutritionalLabel(label: String, value: Float?, unit: UnitsOfMeasure) -> ProductNutritionLabel {
        let nutritionalLabel = ProductNutritionLabel()
        if value != nil {
            nutritionalLabel.text = label + "\r\n\(value ?? 0 )" + unit.rawValue
        } else {
            nutritionalLabel.text = label + "\r\n--"
        }
        nutritionalLabel.snp.makeConstraints { (make) in
            make.height.equalTo(70)
        }
        return nutritionalLabel
    }
    
    func addNutritionLabels(calorieTotal: Float?, saturatedFatTotal: Float?, sodiumTotal: Float?, sugarTotal: Float?) {
        productNutritionStackView.addArrangedSubview(createNutritionalLabel(label: "Calorie", value: calorieTotal, unit: UnitsOfMeasure.none))
        productNutritionStackView.addArrangedSubview(createNutritionalLabel(label: "Sat Fat", value: saturatedFatTotal, unit: UnitsOfMeasure.gram))
        productNutritionStackView.addArrangedSubview(createNutritionalLabel(label: "Sodium", value: sodiumTotal, unit: UnitsOfMeasure.milligram))
        productNutritionStackView.addArrangedSubview(createNutritionalLabel(label: "Sugar", value: sugarTotal, unit: UnitsOfMeasure.gram))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getTotalHeight() -> CGFloat {
        return productFlagGroupStackView.frame.height + productNutritionStackView.frame.height
    }
}
