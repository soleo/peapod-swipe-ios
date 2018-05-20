//
//  PeapodSwipeMarketingUITests.swift
//  PeapodSwipeMarketingUITests
//
//  Created by Xinjiang Shao on 5/19/18.
//  Copyright © 2018 Xinjiang Shao. All rights reserved.
//

import XCTest

class PeapodSwipeMarketingUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
       
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        snapshot("0Launch")
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAppOverallWorkflow() {
        
        let app = XCUIApplication()
        let signInButton = app.buttons["Sign In"]
        XCTAssert(signInButton.exists, "Sign In Button Exists")
       
        signInButton.tap()
        
        snapshot("1SignInScreen")
        
        let signInAlert = app.alerts["Sign In"]
        let collectionViewsQuery = signInAlert.collectionViews
        
        let emailTextField = collectionViewsQuery.textFields["bagel.is.everything@ahold.com"]
        XCTAssert(emailTextField.exists, "Email TextField Exsits")
        emailTextField.tap()
        app.typeText("xinjiang.shao+snapshot@gmail.com")
        
        let inviteCodeTextfield = collectionViewsQuery.textFields["your invite code, like bagels"]
        XCTAssert(inviteCodeTextfield.exists, "Invite Code TextField Exsits")
        inviteCodeTextfield.tap()
        app.typeText("bagels")
        
        signInAlert.buttons["OK"].tap()
        waitForExpectations(timeout: 5, handler: nil)
        //XCTAssert(signInAlert.buttons["OK"].exists, "Sign In Alert OK Button Exsits")
        snapshot("2ProductCardsScreen")
        
        // Swipe
        app.swipeLeft()
        snapshot("3ProductCardDislikeScreen")
        
        waitForExpectations(timeout: 1, handler: nil)
        
        app.swipeRight()
        snapshot("4ProductCardLikeScreen")
        
        waitForExpectations(timeout: 1, handler: nil)
        
        app.collectionViews.images.firstMatch.tap()
        waitForExpectations(timeout: 1, handler: nil)
        snapshot("5ProductDetailScreen")
        
        
    }
}
