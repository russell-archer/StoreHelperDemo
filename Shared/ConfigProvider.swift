//
//  ConfigProvider.swift
//  StoreHelperDemo
//
//  Created by Russell Archer on 14/11/2022.
//

import Foundation
import StoreHelper

/// Override the default configuration values used by StoreHelper.
/// See `Configuration` and `ConfigurationProvider` in Storehelper/Sources/StoreHelper/Util.
/// Use storeHelper.configurationProvider = ConfigProvider() to override default values. See StoreHelperDemoApp for example.
struct ConfigProvider: ConfigurationProvider {
    func value(configuration: Configuration) -> String? {
        switch configuration {
            case .appGroupBundleId:         return nil                                  // If your app supports widgets (e.g. an App Group) that use IAP-based functionality, return the group id that allows the main app and widgets to share data. For example "group.com.{developer}.{appname}". Returning nil means there's no shared data
            case .contactUsUrl:             return nil                                  // A contact URL. Used in the purchase management view
            case .requestRefund:            return "https://reportaproblem.apple.com/"  // A URL which users on macOS can use to request a refund for an IAP
            case .restorePurchasesButton:   return "Restore Purchases"                  // Text to display on the restore purchases button. If nil, the button is not displayed
        }
    }
}
