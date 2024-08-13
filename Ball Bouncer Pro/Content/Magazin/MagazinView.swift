import SwiftUI

struct MagazinView: View {
    
    @Environment(\.presentationMode) var presMode
    @EnvironmentObject var userConfig: UserConfig
    
    @StateObject var storeViewModel = StoreViewModel()
    
    @State var alertPurchaseError = false
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    presMode.wrappedValue.dismiss()
                } label: {
                    Image("close_btn")
                }
                Spacer()
                ZStack {
                    Image("balance_bg")
                    HStack {
                        Text("\(userConfig.credits)")
                            .font(.custom("GrandstanderRoman-Black", size: 32))
                            .foregroundColor(.white)
                        Image("coin")
                    }
                }
                Spacer()
                Spacer()
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.fixed(160)),
                GridItem(.fixed(160))
            ]) {
                ForEach(storeViewModel.products, id: \.id) { product in
                    Button {
                        storeViewModel.selectedProduct = product
                    } label: {
                        ZStack {
                            if storeViewModel.selectedProduct?.id == product.id {
                                Image("store_selected_item_bg")
                            } else {
                                Image("store_unselected_item_bg")
                            }
                            
                            VStack {
                                Image(product.id)
                                if userConfig.selectedBall == product.id {
                                    Image("used")
                                } else {
                                    if storeViewModel.isProductPurchased(product.id) {
                                        Image("purchased")
                                    } else {
                                        HStack {
                                            HStack {
                                                Text("\(product.price)")
                                                    .font(.custom("GrandstanderRoman-Black", size: 24))
                                                    .foregroundColor(.white)
                                                Image("coin")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .padding(.top)
            
            Spacer()
            
            if let selectedProduct = storeViewModel.selectedProduct {
                if selectedProduct.id != userConfig.selectedBall {
                    if storeViewModel.isProductPurchased(selectedProduct.id) {
                        Button {
                            withAnimation {
                                userConfig.selectedBall = selectedProduct.id
                                storeViewModel.selectedProduct = selectedProduct
                            }
                       } label: {
                           Image("use_btn")
                       }
                    } else {
                        Button {
                            alertPurchaseError = !storeViewModel.purchase(product: selectedProduct, userConfig: userConfig)
                        } label: {
                            Image("buy_btn")
                        }
                    }
                }
            }
        }
        .onAppear {
            storeViewModel.selectedProduct = storeViewModel.products[0]
        }
        .background(
            Image("screen_bg")
                .resizable()
                .frame(minWidth: UIScreen.main.bounds.width,
                       minHeight: UIScreen.main.bounds.height)
                .ignoresSafeArea()
        )
        .alert(isPresented: $alertPurchaseError) {
            Alert(title: Text("Purchase Error"), message: Text("Not enough credits to buy the product of your choice!"), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    MagazinView()
        .environmentObject(UserConfig())
}
