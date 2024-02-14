//
//  StoreKitSubscriptionStoreView.swift
//  StoreHelperDemo
//
//  Created by Russell Archer on 13/02/2024.
//

import SwiftUI
import StoreKit
import StoreHelper

struct StoreKitSubscriptionStoreView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var selectedProductId = ""
    @State private var productSelected = false
    
    var body: some View {
        if let products = storeHelper.subscriptionProducts {
            SubscriptionStoreView(subscriptions: products)
            .subscriptionStoreButtonLabel(.action)
            .subscriptionStoreControlStyle(.prominentPicker)
            #if os(iOS)
            .storeButton(.visible, for: .restorePurchases, .redeemCode)
            #elseif os(macOS)
            .storeButton(.visible, for: .restorePurchases)
            #endif
            .subscriptionStoreControlIcon { subscription, info in
                VStack {
                    Image(subscription.id)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onTapGesture {
                            selectedProductId = subscription.id
                            productSelected.toggle()
                        }
                }
            }
            .productViewStyle(.large)
            .storeButton(.hidden, for: .cancellation)  // Hides the close "X" at the top-right of the view
            .sheet(isPresented: $productSelected) {
                StoreKitProductView(selectedProductId: $selectedProductId)
            }
        }
    }
}

#Preview {
    StoreKitSubscriptionStoreView()
}
