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
        app.launchArguments += ["UI_TEST_MODE"]
        setupSnapshot(app)
        app.launch()
        snapshot("0Launch")
    }

    override func tearDown() {
        super.tearDown()
    }

    func waitforExistence(_ element: XCUIElement) {
        let exists = NSPredicate(format: "exists == true")

        expectation(for: exists, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 20, handler: nil)
    }

    func waitforNoExistence(_ element: XCUIElement) {
        let exists = NSPredicate(format: "exists != true")

        expectation(for: exists, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 20, handler: nil)
    }

    func
        testAppOverallWorkflow() {

        let app = XCUIApplication()

        if app.buttons["Menu"].exists {
            app.buttons["Menu"].tap()
            app.sheets["Menu"].buttons["Settings"].tap()
            let tableView = app.tables["AppSettingsTableViewController.tableView"]
            tableView.staticTexts["Log Out"].tap()

        }
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
        waitforExistence(app.buttons["Menu"])
        snapshot("2ProductCardsScreen")

        // Swipe
        app.swipeLeft()
        snapshot("3ProductCardDislikeScreen")
        XCTAssert(app.buttons["Dislike"].exists, "Dislike Button Exsits")

        app.swipeRight()
        snapshot("4ProductCardLikeScreen")
        XCTAssert(app.buttons["Like"].exists, "Like Button Exsits")

        // open item details
        let productImage = app.images.firstMatch
        productImage.tap()
        XCTAssert(productImage.exists, "Item Image Exsits")
        snapshot("5ProductDetailScreen")
        productImage.tap() // close it

        app.buttons["Menu"].tap()
        snapshot("6MenuScreen")

        let menu = app.sheets["Menu"]
        menu.buttons["Search Product"].tap()

        let searchProductSearchField = app.searchFields["Search Product ..."]
        searchProductSearchField.tap()
        searchProductSearchField.typeText("Bagel")
        searchProductSearchField.typeText("\n")

        snapshot("7ProductSearchScreen")

        app.swipeUp()
        app.swipeDown()

        app.tables["SearchTableViewController.tableView"].staticTexts["Bagels Everything - 3 ct"].tap()
        snapshot("8SearchDetailScreen")
    }

}
