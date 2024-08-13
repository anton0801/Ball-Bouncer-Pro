import Foundation

class StoreViewModel: ObservableObject {
    
    @Published var products: [Product]
    @Published var purchasedProductIdentifiers: Set<String>
    @Published var selectedProduct: Product? = nil
    
    private let purchasedKey = "purchasedProducts"
    private let coinsKey = "userCoins"
    
    init() {
        self.products = [
            Product(id: "ball_first", name: "Ball First", description: "Description for Product 1", price: 0),
            Product(id: "ball_second", name: "Ball Second", description: "Description for Product 2", price: 150),
            Product(id: "ball_third", name: "Ball Third", description: "Description for Product 3", price: 300),
            Product(id: "ball_four", name: "Ball Four", description: "Description for Product 3", price: 1000)
        ]
        
        if let savedProducts = UserDefaults.standard.array(forKey: purchasedKey) as? [String] {
            self.purchasedProductIdentifiers = Set(savedProducts)
        } else {
            self.purchasedProductIdentifiers = []
        }
        
        if purchasedProductIdentifiers.isEmpty {
            purchasedProductIdentifiers.insert(products[0].id)
            saveState()
        }
        
    }
    
    func purchase(product: Product, userConfig: UserConfig) -> Bool {
        guard userConfig.credits >= product.price else { return false }
        userConfig.credits -= product.price
        purchasedProductIdentifiers.insert(product.id)
        saveState()
        return true
    }
    
    func isProductPurchased(_ productID: String) -> Bool {
        return purchasedProductIdentifiers.contains(productID)
    }
    
    private func saveState() {
        UserDefaults.standard.set(Array(purchasedProductIdentifiers), forKey: purchasedKey)
    }
    
}

struct Product: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let price: Int
}
