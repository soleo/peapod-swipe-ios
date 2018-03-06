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


class CardViewController: UIViewController {
    
    var cards = [ImageCard]()
    var products = [RecommendedProduct]()
    let menuButton = UIButton()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
//    override func viewWillTransition(to size: CGSize,
//                            with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//
//
//        if UIDevice.current.orientation.isLandscape {
//
//
//        }
//        else if UIDevice.current.orientation.isPortrait {
//
//        }
//
//
//    }
    
    func removeAllCards() {
        for card in cards {
            card.removeFromSuperview()
        }
    }
    
    func loadRecommendationData() {
        Alamofire.request(
            RecommendationRouter.getProducts(100)
            )
            .validate()
            .responseObject{ (response: DataResponse<RecommendedProductsResponse>) in
                
                if let productsResult = response.value {
                    self.products = productsResult.products
                    //print(productsResult)
                    for product in productsResult.products {
                        //print(product)
                        let cardFrameSize: CGRect
                        if UIDevice.current.orientation.isLandscape {
                            cardFrameSize = CGRect(x: 0, y: 0, width: self.view.frame.width * 0.3, height: self.view.frame.height - 120)
                        } else {
                            cardFrameSize = CGRect(x: 0, y: 0, width: self.view.frame.width - 60, height: self.view.frame.height * 0.7)
                        }
                        let card = ImageCard(frame: cardFrameSize, product: product)
                        self.cards.append(card)
                        self.layoutCards()
                    }
                }
        }
    }
    
    func castProductVote(productId: Int, userVote: Bool) {
        Alamofire.request(
            VoteRouter.postVote(productId, userVote)
            )
            .validate()
            .responseString{ (response: DataResponse<String>) in
                print("{ like: \(userVote), productId: \(productId) }")
                if let voteResult = response.value {
                    print(voteResult)
                }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.Defaults.backgroundColor
        dynamicAnimator = UIDynamicAnimator(referenceView: self.view)
        setUpUI()
        
        loadRecommendationData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let cardAttributes: [(downscale: CGFloat, alpha: CGFloat)] = [(1, 1), (0.92, 0.8), (0.84, 0.6), (0.76, 0.4)]
    let cardInteritemSpacing: CGFloat = 15
    
    func setUpUI() {
       
        menuButton.setTitle("MENU", for: UIControlState())
        menuButton.setTitleColor(.white, for: UIControlState())
        menuButton.addTarget(self, action: #selector(CardViewController.SELtoggleMenu), for: .touchUpInside)
        self.view.addSubview(menuButton)
        
        menuButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalTo(120)
            make.centerX.equalToSuperview()
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
        firstCard.likeButton.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(CardViewController.SELhandleLikeTap)))
        firstCard.dislikeButton.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(CardViewController.SELhandleDislikeTap)))
        firstCard.imageView.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(CardViewController.SELhandleProductImageTap)))
        // the next 3 cards in the deck
        for i in 1...3 {
            if i > (cards.count - 1) { continue }
            
            let card = cards[i]
            
            card.layer.zPosition = CGFloat(cards.count - i)
            
            // here we're just getting some hand-picked vales from cardAttributes (an array of tuples)
            // which will tell us the attributes of each card in the 4 cards visible to the user
            let downscale = cardAttributes[i].downscale
            let alpha = cardAttributes[i].alpha
            card.transform = CGAffineTransform(scaleX: downscale, y: downscale)
            card.alpha = alpha
            
            // position each card so there's a set space (cardInteritemSpacing) between each card, to give it a fanned out look
            card.center.x = self.view.center.x
            card.frame.origin.y = cards[0].frame.origin.y - (CGFloat(i) * cardInteritemSpacing)
            // workaround: scale causes heights to skew so compensate for it with some tweaking
            if i == 3 {
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
        for i in 1...3 {
            if i > (cards.count - 1) { continue }
            let card = cards[i]
            let newDownscale = cardAttributes[i - 1].downscale
            let newAlpha = cardAttributes[i - 1].alpha
            UIView.animate(withDuration: animationDuration, delay: (TimeInterval(i - 1) * (animationDuration / 2)), usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [], animations: {
                card.transform = CGAffineTransform(scaleX: newDownscale, y: newDownscale)
                card.alpha = newAlpha
                if i == 1 {
                    card.center = self.view.center
                } else {
                    card.center.x = self.view.center.x
                    card.frame.origin.y = self.cards[1].frame.origin.y - (CGFloat(i - 1) * self.cardInteritemSpacing)
                }
            }, completion: { (_) in
                if i == 1 {
                    
                    card.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(CardViewController.SELhandleCardPan)))
                    card.likeButton.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(CardViewController.SELhandleLikeTap)))
                    card.dislikeButton.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(CardViewController.SELhandleDislikeTap)))
                    card.imageView.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(CardViewController.SELhandleProductImageTap)))
                }
            })
            
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
        UIView.animate(withDuration: animationDuration, delay: (3 * (animationDuration / 2)), usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [], animations: {
            newCard.transform = CGAffineTransform(scaleX: downscale, y: downscale)
            newCard.alpha = alpha
            newCard.center.x = self.view.center.x
            newCard.frame.origin.y = self.cards[1].frame.origin.y - (3 * self.cardInteritemSpacing) + 1.5
        }, completion: nil)
        
        // first card needs to be in the front for proper interactivity
        cards[1].removeAccessibilityHidden()
        self.view.bringSubview(toFront: cards[1])
    }
    
    /// Whenever the front card is off the screen, this method is called in order to remove the card from our data structure and from the view.
    func removeOldFrontCard() {
        cards[0].removeFromSuperview()
        cards.remove(at: 0)
    }
    
    /// UIKit dynamics variables that we need references to.
    var dynamicAnimator: UIDynamicAnimator!
    var cardAttachmentBehavior: UIAttachmentBehavior!
    
    /// This function continuously checks to see if the card's center is on the screen anymore. If it finds that the card's center is not on screen, then it triggers removeOldFrontCard() which removes the front card from the data structure and from the view.
    func hideFrontCard() {
        if #available(iOS 10.0, *) {
            var cardRemoveTimer: Timer? = nil
            cardRemoveTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true, block: { [weak self] (_) in
                guard self != nil else { return }
                if !(self!.view.bounds.contains(self!.cards[0].center)) {
                    cardRemoveTimer!.invalidate()
                    UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn], animations: { [weak self] in
                        guard self != nil else { return }
                        self!.cards[0].alpha = 0.0
                        }, completion: { [weak self] (_) in
                            self!.removeOldFrontCard()
                    })
                }
            })
        } else {
            // fallback for earlier versions
            UIView.animate(withDuration: 0.2, delay: 1.5, options: [.curveEaseIn], animations: {
                self.cards[0].alpha = 0.0
            }, completion: { (_) in
                self.removeOldFrontCard()
            })
        }
    }

}

extension CardViewController {
    @objc func SELhandleLikeTap (_ sender: UITapGestureRecognizer) {
        switch sender.state {
            case .began: break
            case .cancelled: break
            case .failed: break
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
                
                angular = angular * -1
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
        let requiredOffsetFromCenter: CGFloat = 15
        
        let panLocationInView = sender.location(in: view)
        let panLocationInCard = sender.location(in: cards[0])
        switch sender.state {
        case .began:
            dynamicAnimator.removeAllBehaviors()
            let offset = UIOffsetMake(panLocationInCard.x - cards[0].bounds.midX, panLocationInCard.y - cards[0].bounds.midY);
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
                    angular = angular * 1
                    Analytics.logEvent("dislike_a_product", parameters: nil)
                    castProductVote(productId: cards[0].productId, userVote: false)
                    
                } else {
                    angular = angular * -1
                    Analytics.logEvent("like_a_product", parameters: nil)
                    castProductVote(productId: cards[0].productId, userVote: true)
                }
                let itemBehavior = UIDynamicItemBehavior(items: [cards[0]])
                itemBehavior.friction = 0.2
                itemBehavior.allowsRotation = true
                itemBehavior.addAngularVelocity(CGFloat(angular), for: cards[0])
                dynamicAnimator.addBehavior(itemBehavior)
                
                hideFrontCard()
                showNextCard()
            }
        default:
            break
        }
    }
    
    @objc func SELtoggleMenu() {
        
        let alertController = UIAlertController(title: "Menu", message: nil, preferredStyle: .actionSheet)
        
        //let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: nil)
        let itemSuggestionAction = UIAlertAction(title: "Suggest Other Items", style: .default, handler: {(alert: UIAlertAction!) in
            self.presentSearchView()
            
        })
        let logoutAction = UIAlertAction(title: "Logout", style: .default, handler:{(alert: UIAlertAction!) in
            self.logoutCurrentUser()
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        //alertController.addAction(settingsAction)
        alertController.addAction(itemSuggestionAction)
        alertController.addAction(logoutAction)
        alertController.addAction(cancelAction)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = self.menuButton
                popoverController.sourceRect = self.menuButton.bounds
            }
        }
        
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
    
    func logoutCurrentUser() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        Analytics.logEvent("log_out", parameters: nil)
        let authViewController = AuthViewController()
        return self.present(authViewController, animated: true, completion: nil)
        
    }
    
    func presentSearchView() {
        Analytics.logEvent("search_item", parameters: nil)
        let searchViewController = SearchViewController()
        return self.present(searchViewController, animated: true, completion: nil)
        
    }
}

