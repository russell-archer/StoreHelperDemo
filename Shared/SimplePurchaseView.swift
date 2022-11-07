//
//  SimplePurchaseView.swift
//  StoreHelperDemo
//
//  Created by Russell Archer on 19/10/2022.
//

import SwiftUI
import StoreKit
import StoreHelper

struct SimplePurchaseView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State var purchaseState: PurchaseState = .unknown
    var price = "1.99"
    let productId = "com.rarcher.nonconsumable.flowers.large"
    
    var body: some View {
        VStack {
            CustomPurchaseButton(purchaseState: $purchaseState, productId: productId, price: price)
        }
        .task { await purchaseState(for: productId)}
        .onChange(of: storeHelper.purchasedProducts) { _ in
            Task.init {
                await purchaseState(for: productId)
            }
        }
    }
    
    func purchaseState(for productId: ProductId) async {
        let purchased = (try? await storeHelper.isPurchased(productId: productId)) ?? false
        purchaseState = purchased ? .purchased : .unknown
    }
}

/// Provides a button that enables the user to purchase a product.
/// The product's price is also displayed in the localized currency.
public struct CustomPurchaseButton: View {
    
    @EnvironmentObject var storeHelper: StoreHelper
    @Binding var purchaseState: PurchaseState
    
    var productId: ProductId
    var price: String
    
    public var body: some View {
        
        let product = storeHelper.product(from: productId)
        if product == nil {
            
            Text("Error")
            
        } else {
            
            HStack {
                
                if product!.type == .consumable {
                    
                    if purchaseState != .purchased { withAnimation { CustomBadgeView(purchaseState: $purchaseState) }}
                    CustomPriceView(purchaseState: $purchaseState, productId: productId, price: price, product: product!)
                    
                } else {
                    
                    withAnimation { CustomBadgeView(purchaseState: $purchaseState) }
                    if purchaseState != .purchased { CustomPriceView(purchaseState: $purchaseState, productId: productId, price: price, product: product!) }
                }
            }
        }
    }
}

/// Displays a product price and a button that enables purchasing.
public struct CustomPriceView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var canMakePayments: Bool = false
    @Binding var purchaseState: PurchaseState  // Propagates the result of a purchase back from `PriceViewModel`
    
    var productId: ProductId
    var price: String
    var product: Product
    
    public var body: some View {
        
        let priceViewModel = PriceViewModel(storeHelper: storeHelper, purchaseState: $purchaseState)
        
        HStack {
            
            #if os(iOS)
            Button(action: {
                withAnimation { purchaseState = .inProgress }
                Task.init { await priceViewModel.purchase(product: product) }
            }) {
                CustomPriceButtonText(price: price, disabled: !canMakePayments)
            }
            .disabled(!canMakePayments)
            #elseif os(macOS)
            HStack { PriceButtonText(price: price, disabled: !canMakePayments)}
                .contentShape(Rectangle())
                .onTapGesture {
                    guard canMakePayments else { return }
                    withAnimation { purchaseState = .inProgress }
                    Task.init { await priceViewModel.purchase(product: product) }
                }
            #endif
        }
        .onAppear { canMakePayments = AppStore.canMakePayments }
    }
}

public struct CustomPriceButtonText: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    
    @EnvironmentObject var storeHelper: StoreHelper
    var price: String
    var disabled: Bool
    
    public var body: some View {
        Text(disabled ? "Disabled" : price)  // Don't use scaled fonts for the price at it can lead to truncation
            .font(.body)
            .foregroundColor(.white)
            .padding()
            #if os(iOS)
            .frame(height: 40)
            #elseif os(macOS)
            .frame(height: 40)
            #endif
            .fixedSize()
            .background(Color.blue)
            .cornerRadius(25)
    }
}

/// Displays a small image that gives a visual clue to the product's purchase state.
public struct CustomBadgeView: View {
    
    @Binding var purchaseState: PurchaseState
    
    public var body: some View {
        
        if let options = badgeOptions() {
            Image(systemName: options.badgeName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
                .foregroundColor(options.fgColor)
        }
    }
    
    public func badgeOptions() -> (badgeName: String, fgColor: Color)? {
        switch purchaseState {
            case .notStarted:               return nil
            case .userCannotMakePayments:   return (badgeName: "nosign", Color.red)
            case .inProgress:               return (badgeName: "hourglass", Color.cyan)
            case .purchased:                return (badgeName: "checkmark", Color.green)
            case .pending:                  return (badgeName: "hourglass", Color.orange)
            case .cancelled:                return (badgeName: "person.crop.circle.fill.badge.xmark", Color.blue)
            case .failed:                   return (badgeName: "hand.raised.slash", Color.red)
            case .failedVerification:       return (badgeName: "hand.thumbsdown.fill", Color.red)
            case .unknown:                  return nil
        }
    }
}
