//
//  StoreHelperTests.swift
//  StoreHelperTests
//
//  Created by Russell Archer on 03/02/2023.
//

/*
 
 Tests may be run from Xcode by clicking the diamond indicators in the test class, or from the command line as follows:
 - Open Terminal and navigate to the top-level folder that holds the project
 - Build and run your tests: xcodebuild test -scheme StoreHelperTests -sdk iphonesimulator16.2 -destination "OS=16.2,name=iPhone 14 Pro Max"
 - If required:
 -      list the available schemes in your project with: xcodebuild -list
 -      list available SDKs and simulators with: xcodebuild -showsdks
 
 */

import XCTest
import StoreKitTest
@testable import StoreHelper

final class StoreHelperTests: XCTestCase {
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
    
    @MainActor func testPurchase() async throws {
        XCTAssert(sut.hasStarted)
        XCTAssert(sut.hasProducts)
        
        guard let productId = sut.nonConsumableProductIds?.first else {
            XCTFail("No non-consumable products")
            return
        }
        
        guard let product = sut.product(from: productId) else {
            XCTFail("Cannot get product from \(productId)")
            return
        }
        
        guard let result = try? await sut.purchase(product) else {
            XCTFail("Could not purchase product \(productId)")
            return
        }

        XCTAssert(result.purchaseState == .purchased)
    }
}

