import SwiftUI
import SpriteKit

struct LeveledGameView: View {
    
    @Environment(\.presentationMode) var pre
    @EnvironmentObject var levelManager: LevelsManager
    @EnvironmentObject var userConfig: UserConfig
    var level: Int
    
    @State var goToSettings = false
    
    var body: some View {
        NavigationView {
            VStack {
                SpriteView(scene: LeveledGameScene(level: level))
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
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("win"))) { notif in
            guard let userInfo = notif.userInfo,
                  let credits = userInfo["credits"] as? Int else { return }
            levelManager.unlockLevel(id: level + 1)
            userConfig.credits = credits
        }
    }
}

#Preview {
    LeveledGameView(level: 1)
        .environmentObject(LevelsManager())
        .environmentObject(UserConfig())
}
