//
//  StoreHelperDemoApp.swift
//  Shared
//
//  Created by Russell Archer on 24/01/2022.
//

import SwiftUI
import StoreHelper

@main
struct StoreHelperDemoApp: App {
    var body: some Scene {
        WindowGroup {
            MainView().environmentObject(StoreHelper())
                #if os(macOS)
                .frame(minWidth: 700, idealWidth: 700, minHeight: 700, idealHeight: 700)
                .font(.title2)
                #endif
        }
    }
}
