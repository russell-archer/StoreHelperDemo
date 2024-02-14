//
//  MainView.swift
//  StoreHelperDemo
//
//  Created by Russell Archer on 25/01/2022.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
struct MainView: View {
    let largeFlowersId = "com.rarcher.nonconsumable.flowers.large"
    let smallFlowersId = "com.rarcher.nonconsumable.flowers.small"
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: ContentView()) { Text("Product List").font(.title2).padding()}
                NavigationLink(destination: ProductView(productId: largeFlowersId)) { Text("Large Flowers").font(.title2).padding()}
                NavigationLink(destination: ProductView(productId: smallFlowersId)) { Text("Small Flowers").font(.title2).padding()}
                NavigationLink(destination: SubscriptionView()) { Text("Subscriptions").font(.title2).padding()}
                NavigationLink(destination: SimplePurchaseView()) { Text("Simple Purchase").font(.title2).padding()}
                NavigationLink(destination: StoreKitStoreView()) { Text("StoreKit:\nStoreView").font(.title2).padding()}
                NavigationLink(destination: StoreKitSubscriptionStoreView()) { Text("StoreKit:\nSubscriptionStoreView").font(.title2).padding()}
            }
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        .navigationBarTitle(Text("StoreHelperDemo"), displayMode: .large)
        #endif
    }
}
