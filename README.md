#  StoreHelperDemo

Implementing and testing in-App purchases with `StoreKit2` and `StoreHelper` in **Xcode 14** with **SwiftUI**, **Swift 5.7**, **iOS 16** and **macOS 13**.

---

# Description
![](./readme-assets/StoreHelperDemo0c.png)

- See [StoreHelper](https://github.com/russell-archer/StoreHelper) for an overview of the `StoreHelper` package
- See [StoreHelper Guide](https://github.com/russell-archer/StoreHelper/blob/main/Documentation/guide.md) for in-depth discussion and tutorial on using `StoreHelper`, `StoreKit2` with **Xcode 13**, **iOS 15** and **macOS 12**

This document describes how to create an example app that demonstrates how to support in-app purchases with **SwiftUI**, `StoreHelper`, `StoreKit2`, **Xcode 14** with **SwiftUI**, **Swift 5.7**, **iOS 16** and **macOS 13**.
Note that **Xcode 13**, **iOS 15** and **macOS 12** are also supported.

- See [StoreHelper](https://github.com/russell-archer/StoreHelper) for full details of the `StoreHelper` package
- See [In-App Purchases with Xcode 12 and iOS 14](https://github.com/russell-archer/IAPDemo) for details of working with StoreKit1 in **iOS 14**

---

# Quick Start
The following steps show to use `StoreHelper` to create a bare-bones SwiftUI demo app that supports in-app purchases on **iOS 16** and **macOS 13**.
**iOS 15** and **macOS 12** are also supported.

## What you'll need
- **Xcode 14** or **Xcode 13** installed on your Mac
- Basic familiarity with **Xcode**, **Swift** and **SwiftUI**
- About 15-minutes!

# Steps
## Getting the StoreHelper Package
- Open Xcode and create a new project. Use either the **iOS app**, **macOS app** or **multi-platform app** template. These steps use the multi-platform template to create an app named **"StoreHelperDemo"**
- Select **File > Add Packages...**
- Paste the URL of the `StoreHelper` package into the search box: 

    - https://github.com/russell-archer/StoreHelper

- Click **Add Package**:

![](./readme-assets/StoreHelperDemo101.png)

- Xcode will fetch the package from GitHub and then display a confirmation. Click **Add Package**:

![](./readme-assets/StoreHelperDemo102.png)

- The project should now look like this:

![](./readme-assets/StoreHelperDemo103.png)

- Notice that the `StoreHelper` and `swift-collections` packages have been added to the project. `swift-collections` is a package dependency for `StoreHelper`
- If you expand the `StoreHelper` package you'll be able to see the source:

![](./readme-assets/StoreHelperDemo104.png)

- Select the project's **iOS target**. Notice that `StoreHelper` has been added as a library:

![](./readme-assets/StoreHelperDemo105.png)

- Now select the **macOS target**. You'll see that `StoreHelper` has **not** been added as a library
- Click the **+** to add a library, then select **StoreHelper Package > StoreHelper** and click **Add**:

![](./readme-assets/StoreHelperDemo106.png)

## Create the App struct
- Open `StoreHelperExampleApp.swift` and replace the existing code with the following:

> Alternatively, you can copy everything required for the **StoreHelperDemo** app from the **StoreHelper > Samples** folder:
> - Copy all files in **StoreHelper > Samples > Code** into your project's **Shared** folder
> - Copy all files in **StoreHelper > Samples > Configuration** into your project's **Shared** folder
> - Add all the images in **StoreHelper > Samples > Images** to your project's **Asset Catalog** folder

```swift
import SwiftUI
import StoreHelper

@main
struct StoreHelperDemoApp: App {
    @StateObject var storeHelper = StoreHelper()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(storeHelper)
                .onAppear { storeHelper.start() }  // Start listening for transactions, get localized product info
                #if os(macOS)
                .frame(minWidth: 700, idealWidth: 700, minHeight: 700, idealHeight: 700)
                .font(.title2)
                #endif
        }
    }
}
```

- Notice how we `import StoreHelper`, create an instance of the `StoreHelper` class and add it to the SwiftUI view hierarchy using the `.environment()` modifier 
- We also call `StoreHelper.start()` to start listening for transactions and get localized product info

## Create MainView
- Create a new SwiftUI `View` in the **Shared** folder named `MainView` and replace the existing code with the following:

```swift
import SwiftUI

struct MainView: View {
    let largeFlowersId = "com.rarcher.nonconsumable.flowers.large"
    let smallFlowersId = "com.rarcher.nonconsumable.flowers.small"
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ContentView()) { Text("Product List").font(.largeTitle).padding()}
                NavigationLink(destination: ProductView(productId: largeFlowersId)) { Text("Large Flowers").font(.largeTitle).padding()}
                NavigationLink(destination: ProductView(productId: smallFlowersId)) { Text("Small Flowers").font(.largeTitle).padding()}
            }
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        .navigationBarTitle(Text("StoreHelperDemo"), displayMode: .large)
        #endif
    }
}
```

- `MainView` provides simple navigation to `ContentView`, which shows a list of available products, and `ProductView` which gives the user access to a particular product if they've purchased it
- Notice how we pass the `ProductId` for either the "Large Flowers" or "Small Flowers" product to `ProductView`

## Create ProductView
- Create a new SwiftUI `View` named `ProductView` and save it to the **Shared** folder. Replace the existing code with the following:

```swift
import SwiftUI
import StoreHelper

struct ProductView: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var isPurchased = false
    var productId: ProductId
    
    var body: some View {
        VStack {
            if isPurchased {
                Image(productId).bodyImage()
                Text("You have purchased this product and have full access 😀").font(.title).foregroundColor(.green)
            } else {
                Text("Sorry, you have not purchased this product and do not have access 😢").font(.title).foregroundColor(.red)
            }
        }
        .padding()
        .task {
            if let purchased = try? await storeHelper.isPurchased(productId: productId) {
                isPurchased = purchased
            }
        }
    }
}
```

- Notice that when the `VStack` appears we asynchronously call `StoreHelper.isPurchased(productId:)` to see if the user has purchased the product 

## Modify ContentView
- Open `ContentView.swift` and replace the existing code with the following:

```swift
import SwiftUI
import StoreHelper

struct ContentView: View {
    @State private var showProductInfoSheet = false
    @State private var productId: ProductId = ""
    
    var body: some View {
        ScrollView {
            Products() { id in
                productId = id
                showProductInfoSheet = true
            }
            .sheet(isPresented: $showProductInfoSheet) {
                VStack {
                    // Pull in text and images that explain the particular product identified by `productId`
                    ProductInfo(productInfoProductId: $productId, showProductInfoSheet: $showProductInfoSheet)
                }
                #if os(macOS)
                .frame(minWidth: 500, idealWidth: 500, maxWidth: 500, minHeight: 500, idealHeight: 500, maxHeight: 500)
                #endif
            }
        }
    }
}
```

- The above creates the `StoreHelper Products` view. This view displays a list of your configured products (we haven't configured them yet), allow the user to purchase products and see detailed information about purchases
- If the user taps on a product's **More Info** button, the `Products` view provides the unique `ProductId` of that product to our app via a closure. We can then display a view or (as in this example) sheet showing details of the product, and why the user might want to purchase it
- We hand-off the presentation of our product information details to the (as yet undefined) `ProductInfo` view

## Create the ProductInfo View
- Create a new SwiftUI view in the **Shared** folder named `ProductInfo.swift`. Replace the existing code with the following:

```swift
import SwiftUI
import StoreHelper
import StoreKit

struct ProductInfo: View {
    @EnvironmentObject var storeHelper: StoreHelper
    @State private var product: Product?
    @Binding var productInfoProductId: ProductId
    @Binding var showProductInfoSheet: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "xmark.circle")
                    .foregroundColor(.secondary)
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
            }
            .onTapGesture { withAnimation { showProductInfoSheet = false }}
            ScrollView {
                VStack {
                    if let p = product {
                        Text(p.displayName).font(.largeTitle).foregroundColor(.blue)
                        Image(p.id)
                            .resizable()
                            .frame(maxWidth: 200, maxHeight: 200)
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(25)
                    }
                    
                    // Pull in the text appropriate for the product
                    switch productInfoProductId {
                        case "com.rarcher.nonconsumable.flowers.large": ProductInfoFlowersLarge()
                        case "com.rarcher.nonconsumable.flowers.small": ProductInfoFlowersSmall()
                        default: ProductInfoDefault()
                    }
                }
                .padding(.bottom)
            }
        }
        .onAppear {
            product = storeHelper.product(from: productInfoProductId)
        }
    }
}

struct ProductInfoFlowersLarge: View {
    @ViewBuilder var body: some View {
        Text("This is a information about the **Large Flowers** product.").font(.title2).padding().multilineTextAlignment(.center)
        Text("Add text and images explaining this product here.").font(.title3).padding().multilineTextAlignment(.center)
    }
}

struct ProductInfoFlowersSmall: View {
    @ViewBuilder var body: some View {
        Text("This is a information about the **Small Flowers** product.").font(.title2).padding().multilineTextAlignment(.center)
        Text("Add text and images explaining this product here.").font(.title3).padding().multilineTextAlignment(.center)
    }
}

struct ProductInfoDefault: View {
    @ViewBuilder var body: some View {
        Text("This is generic information about a product.").font(.title2).padding().multilineTextAlignment(.center)
        Text("Add text and images explaining your product here.").font(.title3).padding().multilineTextAlignment(.center)
    }
}
```

- `ProductInfo` uses `StoreHelper.product(from:)` to retrieve a `StoreKit2 Product` struct, which gives localized information about the product

## Add Product Images
- From the **StoreHelper > Samples > Images** folder, drag all the images into the project's **Asset Catalog**. These images have filenames that are the same as the product ids for the products which they represent

## Add Product Configuration Files
- From the **StoreHelper > Samples > Configuration** folder, drag the `Products.storekit` and `Products.plist` files into the **Shared** project folder. These are example product configuration files
- Select the **iOS target** and select **Product > Scheme> Edit Scheme**. Select the `Products.storekit` file in the **StoreKit Configuration** field:

![](./readme-assets/StoreHelperDemo107.png)

- Repeat the previous step for the **macOS target**

## Run the App
- Select the **iOS target** and run it in the simulator:
    - The MainView provides navigation to the **Products List** and product access views
    - The **Products List** view displays a list of products, along with images and descriptions
    - Try purchasing the **Large Flowers** product
    - Your demo app supports a complete range of in-app purchase-related features. See the documentation for `StoreHelper` for a full list of features
    - Try selecting "Large Flowers" from the main view. If you've purchased it you should see that you have access, otherwise you'll see a "no access" error 

![](./readme-assets/StoreHelperDemo108.png)

- Now select the **macOS target** and run it on your Mac:

![](./readme-assets/StoreHelperDemo108b.png)

![](./readme-assets/StoreHelperDemo108c.png)

---

### See [StoreHelper](https://github.com/russell-archer/StoreHelper) for full details of the `StoreHelper` package
