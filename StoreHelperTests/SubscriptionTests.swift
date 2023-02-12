//
//  SubscriptionTests.swift
//  StoreHelperTests
//
//  Created by Russell Archer on 10/02/2023.
//

import XCTest
import StoreKitTest
@testable import StoreHelper

final class SubscriptionTests: XCTestCase {
    var sut = StoreHelper()  // System under test
    var session: SKTestSession?
    
    override func setUp() async throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        await sut.startAsync()
        
        session = try? SKTestSession(configurationFileNamed: "Products")
        guard let session else { return }
        session.resetToDefaultState()
        session.disableDialogs = true
        session.clearTransactions()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        session = nil
    }
    
    func testGroups() {
        let subscriptionHelper = SubscriptionHelper(storeHelper: sut)
        XCTAssert(sut.hasStarted)
        XCTAssert(sut.hasProducts)
        
        let groups = subscriptionHelper.groups()
        XCTAssertNotNil(groups)
        
        if let groups {
            XCTAssert(groups.count == 2)
            XCTAssert(groups[0] == "vip")
            XCTAssert(groups[1] == "standard")
        }
    }
    
    func testSubscriptions() {
        let subscriptionHelper = SubscriptionHelper(storeHelper: sut)
        XCTAssert(sut.hasStarted)
        XCTAssert(sut.hasProducts)
        
        let subscriptions = subscriptionHelper.subscriptions(in: "vip")
        XCTAssertNotNil(subscriptions)
        
        if let subscriptions {
            XCTAssert(subscriptions.count == 3)
            XCTAssert(subscriptions[0] == "com.rarcher.subscription.vip.gold")
            XCTAssert(subscriptions[1] == "com.rarcher.subscription.vip.silver")
            XCTAssert(subscriptions[2] == "com.rarcher.subscription.vip.bronze")
        }
        
        let subs = subscriptionHelper.subscriptions(in: "standard")
        XCTAssertNotNil(subscriptions)

        if let subs {
            XCTAssert(subs.count == 3)
            XCTAssert(subs[0] == "com.rarcher.green")
            XCTAssert(subs[1] == "com.rarcher.amber")
            XCTAssert(subs[2] == "com.rarcher.red")
        }
    }
    
    func testGroupName() {
        var group = SubscriptionHelper.groupName(from: "com.rarcher.subscription.vip.gold")
        XCTAssertNotNil(group)
        XCTAssert(group == "vip")
        
        group = SubscriptionHelper.groupName(from: "com.rarcher.subscription.vip.silver")
        XCTAssertNotNil(group)
        XCTAssert(group == "vip")

        group = SubscriptionHelper.groupName(from: "com.rarcher.subscription.vip.bronze")
        XCTAssertNotNil(group)
        XCTAssert(group == "vip")

        group = SubscriptionHelper.groupName(from: "com.rarcher.green")
        XCTAssertNotNil(group)
        XCTAssert(group == "standard")

        group = SubscriptionHelper.groupName(from: "com.rarcher.amber")
        XCTAssertNotNil(group)
        XCTAssert(group == "standard")

        group = SubscriptionHelper.groupName(from: "com.rarcher.red")
        XCTAssertNotNil(group)
        XCTAssert(group == "standard")
    }
    
    func testSubscriptionServiceLevel() {
        let subscriptionHelper = SubscriptionHelper(storeHelper: sut)
        var level = subscriptionHelper.subscriptionServiceLevel(in: "vip", for: "com.rarcher.subscription.vip.gold")
        XCTAssert(level == 2)
        
        level = subscriptionHelper.subscriptionServiceLevel(in: "vip", for: "com.rarcher.subscription.vip.silver")
        XCTAssert(level == 1)
        
        level = subscriptionHelper.subscriptionServiceLevel(in: "vip", for: "com.rarcher.subscription.vip.bronze")
        XCTAssert(level == 0)
        
        level = subscriptionHelper.subscriptionServiceLevel(in: "standard", for: "com.rarcher.green")
        XCTAssert(level == 2)
        
        level = subscriptionHelper.subscriptionServiceLevel(in: "standard", for: "com.rarcher.amber")
        XCTAssert(level == 1)
        
        level = subscriptionHelper.subscriptionServiceLevel(in: "standard", for: "com.rarcher.red")
        XCTAssert(level == 0)
    }
}
