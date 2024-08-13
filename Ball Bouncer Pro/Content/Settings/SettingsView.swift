import SwiftUI

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presMode
    @State var soundApp: Bool = UserDefaults.standard.bool(forKey: "soundApp")
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    presMode.wrappedValue.dismiss()
                } label: {
                    Image("close_btn")
                }
                Spacer()
            }
            .padding(.horizontal)
            
            Spacer()
            
            ZStack {
                Image("settings_item_back")
                HStack {
                    Text("SOUNDS")
                          .font(.custom("GrandstanderRoman-Black", size: 32))
                          .foregroundColor(.white)
                          .multilineTextAlignment(.center)
                    Spacer()
                    Toggle(isOn: $soundApp, label: {
                    })
                    .frame(width: 70)
                    .onChange(of: soundApp) { value in
                        soundApp = value
                        UserDefaults.standard.set(value, forKey: "soundApp")
                    }
                }
                .padding(.horizontal, 52)
            }
            
            Spacer()
        }
        .background(
            Image("screen_bg")
                .resizable()
                .frame(minWidth: UIScreen.main.bounds.width,
                       minHeight: UIScreen.main.bounds.height)
                .ignoresSafeArea()
        )
    }
}

#Preview {
    SettingsView()
}
