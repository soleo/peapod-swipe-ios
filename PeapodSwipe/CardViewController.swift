//
//  ViewController.swift
//  peapod swipe
//
//  Created by Xinjiang Shao on 6/12/17.
//  Copyright © 2017 Xinjiang Shao. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SnapKit
import Default

class CardViewController: UIViewController {

    var cards = [ImageCard]()
    var products = [Product]()
    let menuButton = UIButton()
    let cardsViewContainer = UIView()
    let loadingStateView = LoadingStateView()

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.Defaults.backgroundColor
        dynamicAnimator = UIDynamicAnimator(referenceView: self.view)
        configureInitialLayout()
        loadingStateView.isHidden = false
        loadRecommendationData()
    }

    let cardAttributes: [(downscale: CGFloat, alpha: CGFloat)] = [(1, 1), (0.92, 0.8), (0.84, 0.6), (0.76, 0.4)]
    let cardInteritemSpacing: CGFloat = 15

    func configureInitialLayout() {

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Menu", comment: "Menu button on left side of the Settings view controller title bar"),
            style: .plain,
            target: self, action: #selector(self.SELtoggleMenu))
        navigationItem.leftBarButtonItem?.accessibilityIdentifier = "CardViewController.navigationItem.leftBarButtonItem"
        self.view.addSubview(loadingStateView)
        loadingStateView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }

    func loadRecommendationData() {
        let cardFrameSize: CGRect
        if UIDevice.current.orientation.isLandscape {
            cardFrameSize = CGRect(x: 0, y: 100, width: self.view.frame.width * 0.3, height: self.view.frame.height - 120)
        } else {
            cardFrameSize = CGRect(x: 0, y: 100, width: self.view.frame.width - 60, height: self.view.frame.height * 0.7)
        }

        Alamofire.request(
            RecommendationRouter.getProducts(100)
            )
            .validate()
            .responseObject { (response: DataResponse<RecommendedProductsResponse>) in

                if let productsResult = response.value {
                    self.products = productsResult.products
                    for product in productsResult.products {
                        let card = ImageCard(frame: cardFrameSize, product: product)
                        self.cards.append(card)
                    }
                    self.layoutCards()
                    self.loadingStateView.isHidden = true
                }
        }
    }

    func castProductVote(productId: Int, userVote: Bool) {
        Alamofire.request(
            ProductRouter.postVote(productId, userVote)
            )
            .validate()
            .responseString { (response: DataResponse<String>) in
                print("{ like: \(userVote), productId: \(productId) }")
                if let voteResult = response.value {
                    print(voteResult)
                }
        }
    }

    func layoutCards() {
        // set up intial cards for display
        // frontmost card (first card of the deck)
        let firstCard = cards[0]
        self.view.addSubview(firstCard)
        firstCard.layer.zPosition = CGFloat(cards.count)
        firstCard.center = self.view.center
        firstCard.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(CardViewController.SELhandleCardPan)))
        firstCard.likeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CardViewController.SELhandleLikeTap)))
        firstCard.dislikeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CardViewController.SELhandleDislikeTap)))
        firstCard.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CardViewController.SELhandleProductImageTap)))

        // the next 3 cards in the deck
        for cardIndex in 1...3 {
            if cardIndex > (cards.count - 1) { continue }

            let card = cards[cardIndex]

            card.layer.zPosition = CGFloat(cards.count - cardIndex)

            // here we're just getting some hand-picked vales from cardAttributes (an array of tuples)
            // which will tell us the attributes of each card in the 4 cards visible to the user
            let downscale = cardAttributes[cardIndex].downscale
            let alpha = cardAttributes[cardIndex].alpha
            card.transform = CGAffineTransform(scaleX: downscale, y: downscale)
            card.alpha = alpha

            // position each card so there's a set space (cardInteritemSpacing) between each card, to give it a fanned out look
            card.center.x = self.view.center.x
            card.frame.origin.y = cards[0].frame.origin.y - (CGFloat(cardIndex) * cardInteritemSpacing)
            // workaround: scale causes heights to skew so compensate for it with some tweaking
            if cardIndex == 3 {
                card.frame.origin.y += 1.5
            }

            self.view.addSubview(card)
        }

        cards[0].removeAccessibilityHidden()
        // make sure that the first card in the deck is at the front
        self.view.bringSubview(toFront: cards[0])
    }

    /// This is called whenever the front card is swiped off the screen or is animating away from its initial position.
    /// showNextCard() just adds the next card to the 4 visible cards and animates each card to move forward.
    func showNextCard() {
        let animationDuration: TimeInterval = 0.2
        // 1. animate each card to move forward one by one
        for cardIndex in 1...3 {
            if cardIndex > (cards.count - 1) { continue }
            let card = cards[cardIndex]
            let newDownscale = cardAttributes[cardIndex - 1].downscale
            let newAlpha = cardAttributes[cardIndex - 1].alpha
            UIView.animate(
                withDuration: animationDuration,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.0,
                options: [],
                animations: {
                    card.transform = CGAffineTransform(scaleX: newDownscale, y: newDownscale)
                    card.alpha = newAlpha
                    if cardIndex == 1 {
                        card.center = self.view.center
                    } else {
                        card.center.x = self.view.center.x
                        card.frame.origin.y = self.cards[1].frame.origin.y - (CGFloat(cardIndex - 1) * self.cardInteritemSpacing)
                    }
                },
                completion: { (_) in
                    if cardIndex == 1 {

                        card.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(CardViewController.SELhandleCardPan)))
                        card.likeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CardViewController.SELhandleLikeTap)))
                        card.dislikeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CardViewController.SELhandleDislikeTap)))
                        card.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CardViewController.SELhandleProductImageTap)))
                   }
                }
            )

        }

        // 2. add a new card (now the 4th card in the deck) to the very back
        if 4 > (cards.count - 1) {
            if cards.count != 1 {
                cards[1].removeAccessibilityHidden()
                self.view.bringSubview(toFront: cards[1])
            }
            return
        }
        let newCard = cards[4]

        newCard.layer.zPosition = CGFloat(cards.count - 4)
        let downscale = cardAttributes[3].downscale
        let alpha = cardAttributes[3].alpha

        // initial state of new card
        newCard.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        newCard.alpha = 0
        newCard.center.x = self.view.center.x
        newCard.frame.origin.y = cards[1].frame.origin.y - (4 * cardInteritemSpacing)
        self.view.addSubview(newCard)

        // animate to end state of new card
        UIView.animate(
            withDuration: animationDuration,
            delay: (3 * (animationDuration / 2)),
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.0,
            options: [],
            animations: {
                newCard.transform = CGAffineTransform(scaleX: downscale, y: downscale)
                newCard.alpha = alpha
                newCard.center.x = self.view.center.x
                newCard.frame.origin.y = self.cards[1].frame.origin.y - (3 * self.cardInteritemSpacing) + 1.5
            },
            completion: nil)

        // first card needs to be in the front for proper interactivity
        cards[1].removeAccessibilityHidden()
        self.view.bringSubview(toFront: cards[1])
    }

    // Whenever the front card is off the screen,
    // this method is called in order to remove the card from our data structure
    // and from the view.
    func removeOldFrontCard() {
        cards[0].removeFromSuperview()
        cards.remove(at: 0)
    }

    // UIKit dynamics variables that we need references to.
    var dynamicAnimator: UIDynamicAnimator!
    var cardAttachmentBehavior: UIAttachmentBehavior!

    // This function continuously checks to see if the card's center is on the
    // screen anymore. If it finds that the card's center is not on screen,
    // then it triggers removeOldFrontCard() which removes the front card from
    // the data structure and from the view.
    func hideFrontCard() {
//        if #available(iOS 10.0, *) {
//            var cardRemoveTimer: Timer? = nil
//            cardRemoveTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { [weak self] (_) in
//                guard self != nil else { return }
//                if !(self!.view.bounds.contains(self!.cards[0].center)) {
//                    cardRemoveTimer!.invalidate()
//                    UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn], animations: { [weak self] in
//                        guard self != nil else { return }
//                        self!.cards[0].alpha = 0.0
//                        }, completion: { [weak self] (_) in
//                            self!.removeOldFrontCard()
//                    })
//                }
//            })
//        } else {
            // fallback for earlier versions
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: [.curveEaseIn],
                animations: {
                    self.cards[0].alpha = 0.0
                },
                completion: { (_) in
                self.removeOldFrontCard()
                }
            )
        //}
    }

}

extension CardViewController {
    @objc func SELhandleLikeTap (_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .began:
            break
        case .cancelled:
            break
        case .failed:
            break
        case .changed:
             dynamicAnimator.removeAllBehaviors()

        case .ended:
            dynamicAnimator.removeAllBehaviors()

            let pushBehavior = UIPushBehavior(items: [cards[0]], mode: .instantaneous)
            pushBehavior.pushDirection = CGVector(dx: 5, dy: 0)
            pushBehavior.magnitude = 175
            dynamicAnimator.addBehavior(pushBehavior)

            // spin after throwing
            var angular = CGFloat.pi / 2 // angular velocity of spin

            angular *= -1
            Analytics.logEvent("like_a_product", parameters: nil)
            castProductVote(productId: cards[0].productId, userVote: true)

            let itemBehavior = UIDynamicItemBehavior(items: [cards[0]])
            itemBehavior.friction = 0.2
            itemBehavior.allowsRotation = true
            itemBehavior.addAngularVelocity(CGFloat(angular), for: cards[0])
            dynamicAnimator.addBehavior(itemBehavior)

            hideFrontCard()
            showNextCard()
        case .possible:
            break
        }
    }

    @objc func SELhandleDislikeTap (_ sender: UITapGestureRecognizer) {

        switch sender.state {
        case .began: break
        case .cancelled: break
        case .failed: break
        case .changed:
            dynamicAnimator.removeAllBehaviors()
        case .ended:

            dynamicAnimator.removeAllBehaviors()

            let pushBehavior = UIPushBehavior(items: [cards[0]], mode: .instantaneous)
            pushBehavior.pushDirection = CGVector(dx: -200, dy: 0)
            pushBehavior.magnitude = 175
            dynamicAnimator.addBehavior(pushBehavior)

            // spin after throwing
            let angular = CGFloat.pi / 2 // angular velocity of spin

            Analytics.logEvent("dislike_a_product", parameters: nil)
            castProductVote(productId: cards[0].productId, userVote: false)

            let itemBehavior = UIDynamicItemBehavior(items: [cards[0]])
            itemBehavior.friction = 0.2
            itemBehavior.allowsRotation = true
            itemBehavior.addAngularVelocity(CGFloat(angular), for: cards[0])
            dynamicAnimator.addBehavior(itemBehavior)

            hideFrontCard()
            showNextCard()
        case .possible:
            break
        }
    }
    /// This method handles the swiping gesture on each card and shows the appropriate emoji based on the card's center.
    @objc func SELhandleCardPan(_ sender: UIPanGestureRecognizer) {
        // change this to your discretion - it represents how far the user must pan up or down to change the option
        let optionLength: CGFloat = 60
        // distance user must pan right or left to trigger an option
        let requiredOffsetFromCenter: CGFloat = 50

        let panLocationInView = sender.location(in: view)
        let panLocationInCard = sender.location(in: cards[0])
        switch sender.state {
        case .began:
            dynamicAnimator.removeAllBehaviors()
            let offset = UIOffset(
                horizontal: panLocationInCard.x - cards[0].bounds.midX,
                vertical: panLocationInCard.y - cards[0].bounds.midY
            )
            // card is attached to center
            cardAttachmentBehavior = UIAttachmentBehavior(item: cards[0], offsetFromCenter: offset, attachedToAnchor: panLocationInView)
            dynamicAnimator.addBehavior(cardAttachmentBehavior)
        case .changed:
            cardAttachmentBehavior.anchorPoint = panLocationInView
            if cards[0].center.x > (self.view.center.x + requiredOffsetFromCenter) {
                if cards[0].center.y < (self.view.center.y - optionLength) {
                    cards[0].showOptionLabel(.like1)
                } else if cards[0].center.y > (self.view.center.y + optionLength) {
                    cards[0].showOptionLabel(.like3)
                } else {
                    cards[0].showOptionLabel(.like2)
                }
            } else if cards[0].center.x < (self.view.center.x - requiredOffsetFromCenter) {

                if cards[0].center.y < (self.view.center.y - optionLength) {
                    cards[0].showOptionLabel(.dislike1)

                } else if cards[0].center.y > (self.view.center.y + optionLength) {
                    cards[0].showOptionLabel(.dislike3)

                } else {
                    cards[0].showOptionLabel(.dislike2)
                }
            } else {
                cards[0].hideOptionLabel()
            }

        case .ended:

            dynamicAnimator.removeAllBehaviors()

            if !(cards[0].center.x > (self.view.center.x + requiredOffsetFromCenter) || cards[0].center.x < (self.view.center.x - requiredOffsetFromCenter)) {
                // snap to center
                let snapBehavior = UISnapBehavior(item: cards[0], snapTo: self.view.center)
                dynamicAnimator.addBehavior(snapBehavior)
            } else {

                let velocity = sender.velocity(in: self.view)
                let pushBehavior = UIPushBehavior(items: [cards[0]], mode: .instantaneous)
                pushBehavior.pushDirection = CGVector(dx: velocity.x/10, dy: velocity.y/10)
                pushBehavior.magnitude = 175
                dynamicAnimator.addBehavior(pushBehavior)
                // spin after throwing
                var angular = CGFloat.pi / 2 // angular velocity of spin

                let currentAngle: Double = atan2(Double(cards[0].transform.b), Double(cards[0].transform.a))
                if currentAngle > 0 {
                    angular *= 1
                } else {
                    angular *= -1
                }

                let itemBehavior = UIDynamicItemBehavior(items: [cards[0]])
                itemBehavior.friction = 0.2
                itemBehavior.allowsRotation = true
                itemBehavior.addAngularVelocity(CGFloat(angular), for: cards[0])
                dynamicAnimator.addBehavior(itemBehavior)
                // I cannot trust the current angel, it gave me falsy result
                let pushDirection = velocity.x
                if pushDirection > 0 {
                    Analytics.logEvent("like_a_product", parameters: nil)
                    castProductVote(productId: cards[0].productId, userVote: true)
                } else {
                    Analytics.logEvent("dislike_a_product", parameters: nil)
                    castProductVote(productId: cards[0].productId, userVote: false)
                }
                hideFrontCard()
                showNextCard()
            }
        default:
            break
        }
    }

    @objc func SELtoggleMenu(_ sender: UITapGestureRecognizer) {

        let alertController = UIAlertController(
            title: "Menu", message: nil, preferredStyle: .actionSheet
        )

        let itemSuggestionAction = UIAlertAction(
            title: NSLocalizedString("Search Product", comment: "Search Product Action"),
            style: .default,
            handler: {(_: UIAlertAction!) in
                self.presentSearchView()
            }
        )

        let settingsAction = UIAlertAction(
            title: NSLocalizedString("Settings", comment: "Settings Action"),
            style: .default,
            handler: {(_: UIAlertAction!) in
                self.presentSettingView()
            }
        )

        let cancelAction = UIAlertAction(
            title: NSLocalizedString("Cancel", comment: "Cancel"),
            style: .cancel,
            handler: nil
        )

        alertController.addAction(itemSuggestionAction)
        alertController.addAction(settingsAction)

        alertController.addAction(cancelAction)

        self.present(alertController, animated: true)

    }

    @objc func SELhandleProductImageTap (_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .began: break
        case .cancelled: break
        case .failed: break
        case .changed: break
        case .possible: break
        case .ended:

            let productDetailViewController = ProductDetailViewController()
            productDetailViewController.shouldShowNotifyButton = false
            productDetailViewController.productId = cards[0].productId
            self.present(productDetailViewController, animated: true, completion: nil)
        }
    }

    func presentSearchView() {
        Analytics.logEvent("search_item", parameters: nil)
        let searchViewController = SearchViewController()
        return self.present(searchViewController, animated: true, completion: nil)
    }

    func presentSettingView() {
        Analytics.logEvent("settings", parameters: nil)
        let appSettingsTableViewController = AppSettingsTableViewController()
        let controller = SettingsNavigationController(rootViewController: appSettingsTableViewController)
        return self.present(controller, animated: true, completion: nil)
    }
}
