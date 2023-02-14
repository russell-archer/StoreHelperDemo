//
//  ProductConfigurationTests.swift
//  StoreHelperTests
//
//  Created by Russell Archer on 10/02/2023.
//

import XCTest
@testable import StoreHelper

final class ProductConfigurationTests: XCTestCase {
    let storeConfiguration = StoreConfiguration()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testReadConfigProducts() {
        // Read the Products.plist file that contains both "Products" and "Subscriptions" sections
        let productIds = StoreConfiguration.readConfigFile()
        XCTAssertNotNil(productIds)
        
        if let productIds { XCTAssert(productIds.count == 11) }
    }
    
    func testReadConfiguredSubscriptionGroups() {
        let subscriptionGroupInfo = storeConfiguration.readConfiguredSubscriptionGroups()
        XCTAssertNotNil(subscriptionGroupInfo)
        
        if let subscriptionGroupInfo {
            // There should be 2 subscription groups, each with 3 subscription products defined
            XCTAssert(subscriptionGroupInfo.count == 2)
            XCTAssert(subscriptionGroupInfo[0].group == "vip")
            XCTAssert(subscriptionGroupInfo[0].productIds.count == 3)
            XCTAssert(subscriptionGroupInfo[1].group == "standard")
            XCTAssert(subscriptionGroupInfo[1].productIds.count == 3)
        }
    }
}
