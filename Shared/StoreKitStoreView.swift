//
//  StoreKitStoreView.swift
//  StoreHelperDemo
//
//  Created by Russell Archer on 13/02/2024.
//

import SwiftUI
import StoreKit
import StoreHelper

struct StoreKitStoreView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var selectedProductId = ""
    @State private var productSelected = false
    
    var body: some View {
        // Rather than letting StoreView load products from the App Store, use the products previously loaded by StoreHelper
        if let products = storeHelper.nonConsumableProducts {
            StoreView(products: products) { product in
                VStack {
                    Image(product.id)
                        .resizable()
                        .cornerRadius(15)
                        .aspectRatio(contentMode: .fit)
                    
                    Button(action: {
                        selectedProductId = product.id
                        productSelected.toggle()
                        
                    }, label: {
                        HStack {
                            Image(systemName: "info.circle")
                            Text("More info")
                        }
                    })
                }
            }
            .productViewStyle(.large)
            .storeButton(.visible, for: .restorePurchases)
            .storeButton(.hidden, for: .cancellation)  // Hides the close "X" at the top-right of the view
            .sheet(isPresented: $productSelected) {
                StoreKitProductView(selectedProductId: $selectedProductId)
            }
        }
    }
}

#Preview {
    StoreKitStoreView()
}
