//
//  StoreKitProductView.swift
//  StoreHelperDemo
//
//  Created by Russell Archer on 13/02/2024.
//

import SwiftUI
import StoreKit

struct StoreKitProductView: View {
    @Binding var selectedProductId: String
    
    var body: some View {
        StoreKit.ProductView(id: selectedProductId) {
            Image(selectedProductId)
                .resizable()
                .cornerRadius(15)
                .aspectRatio(contentMode: .fit)
            
            Text("Here's some details about why you should buy this product...")
        }
        .padding()
        .productViewStyle(.large)
    }
}

