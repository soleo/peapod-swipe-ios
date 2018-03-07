//
//  CardView.swift
//  peapod swipe
//
//  Created by Xinjiang Shao on 6/12/17.
//  Copyright © 2017 Xinjiang Shao. All rights reserved.
//

import Foundation
import UIKit

public enum CardOption: String {
    case like1 = "I love it!"
    case like2 = "I do like it"
    case like3 = "It's fine"

    case dislike1 = "Terrible!"
    case dislike2 = "I do not"
    case dislike3 = "Not enough"
}

class CardView: UIView {

    var greenLabel: CardViewLabel!
    var redLabel: CardViewLabel!

    override init(frame: CGRect) {
        super.init(frame: frame)

        // card style
        self.backgroundColor = .white
        self.layer.cornerRadius = 10

        // labels on top left and right
        let padding: CGFloat = 30

        greenLabel = CardViewLabel(origin: CGPoint(x: padding, y: padding), color: UIColor.Defaults.primaryColor)
        greenLabel.isHidden = true
        self.addSubview(greenLabel)

        redLabel = CardViewLabel(origin: CGPoint(x: frame.width - CardViewLabel.size.width - padding, y: padding), color: UIColor.Defaults.secondaryColor)
        redLabel.isHidden = true
        self.addSubview(redLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showOptionLabel(_ option: CardOption) {
        if option == .like1 || option == .like2 || option == .like3 {

            greenLabel.text = option.rawValue

            // fade out redLabel
            if !redLabel.isHidden {
                UIView.animate(withDuration: 0.15, animations: {
                    self.redLabel.alpha = 0
                }, completion: { (_) in
                    self.redLabel.isHidden = true
                })
            }

            // fade in greenLabel
            if greenLabel.isHidden {
                greenLabel.alpha = 0
                greenLabel.isHidden = false
                UIView.animate(withDuration: 0.2, animations: {
                    self.greenLabel.alpha = 1
                })
            }

        } else {

            redLabel.text = option.rawValue

            // fade out greenLabel
            if !greenLabel.isHidden {
                UIView.animate(withDuration: 0.15, animations: {
                    self.greenLabel.alpha = 0
                }, completion: { (_) in
                    self.greenLabel.isHidden = true
                })
            }

            // fade in redLabel
            if redLabel.isHidden {
                redLabel.alpha = 0
                redLabel.isHidden = false
                UIView.animate(withDuration: 0.2, animations: {
                    self.redLabel.alpha = 1
                })
            }
        }
    }

    var isHidingOptionLabel = false

    func hideOptionLabel() {
        // fade out greenLabel
        if !greenLabel.isHidden {
            if isHidingOptionLabel { return }
            isHidingOptionLabel = true
            UIView.animate(withDuration: 0.15, animations: {
                self.greenLabel.alpha = 0
            }, completion: { (_) in
                self.greenLabel.isHidden = true
                self.isHidingOptionLabel = false
            })
        }
        // fade out redLabel
        if !redLabel.isHidden {
            if isHidingOptionLabel { return }
            isHidingOptionLabel = true
            UIView.animate(withDuration: 0.15, animations: {
                self.redLabel.alpha = 0
            }, completion: { (_) in
                self.redLabel.isHidden = true
                self.isHidingOptionLabel = false
            })
        }
    }

}
