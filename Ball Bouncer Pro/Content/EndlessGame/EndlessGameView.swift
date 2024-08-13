import SwiftUI
import SpriteKit

struct EndlessGameView: View {
    
    @Environment(\.presentationMode) var pre
    
   @EnvironmentObject var levelManager: LevelsManager
   @EnvironmentObject var userConfig: UserConfig

   @State var goToSettings = false
   
   var body: some View {
       NavigationView {
           VStack {
               SpriteView(scene: EndlessGameScene())
                   .ignoresSafeArea()
               
           NavigationLink(destination: SettingsView()
               .navigationBarBackButtonHidden(true), isActive: $goToSettings) {
                   
               }
           }
       }
       .navigationViewStyle(StackNavigationViewStyle())
       .onReceive(NotificationCenter.default.publisher(for: Notification.Name("to_home"))) { _ in
           pre.wrappedValue.dismiss()
       }
       .onReceive(NotificationCenter.default.publisher(for: Notification.Name("to_settings"))) { _ in
           goToSettings = true
       }
       .onReceive(NotificationCenter.default.publisher(for: Notification.Name("game_over"))) { notif in
           guard let userInfo = notif.userInfo,
                 let credits = userInfo["credits"] as? Int else { return }
           userConfig.credits = credits
       }
   }
}

#Preview {
    EndlessGameView()
        .environmentObject(LevelsManager())
        .environmentObject(UserConfig())
}
