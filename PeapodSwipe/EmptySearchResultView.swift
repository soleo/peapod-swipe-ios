//
//  EmptySearchResultView.swift
//  PeapodSwipe
//
//  Created by Xinjiang Shao on 3/4/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import UIKit
import SnapKit

private struct EmptySearchViewUX {
    
    static let NoResultsFont: UIFont = UIFont.systemFont(ofSize: 16)
    static let NoResultsTextColor: UIColor = UIColor.lightGray
    
}

class EmptySearchResultView: UIView {
    
    // We use the search bar height to maintain visual balance with the whitespace on this screen. The
    // title label is centered visually using the empty view + search bar height as the size to center with.
    var searchBarHeight: CGFloat = 0 {
        didSet {
            setNeedsUpdateConstraints()
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = EmptySearchViewUX.NoResultsFont
        label.textColor = EmptySearchViewUX.NoResultsTextColor
        label.text = "No Result Found! Try Another Keyword?"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
    }
    
    internal override func updateConstraints() {
        super.updateConstraints()
        titleLabel.snp.remakeConstraints { make in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(-(searchBarHeight / 2))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
