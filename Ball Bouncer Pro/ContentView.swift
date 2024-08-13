import SwiftUI

struct ContentView: View {
    
    @StateObject var levelsManager: LevelsManager = LevelsManager()
    @StateObject var userConfig = UserConfig()
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    NavigationLink(destination: MagazinView()
                        .environmentObject(userConfig)
                        .navigationBarBackButtonHidden(true)) {
                        Image("store_btn")
                    }
                    Spacer()
                    NavigationLink(destination: SettingsView()
                        .navigationBarBackButtonHidden(true)) {
                        Image("settings_btn")
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 52.0, style: .continuous)
                        .fill(.white)
                        .frame(height: 220)
                        .opacity(0.2)
                    
                    LazyVGrid(columns: [
                        GridItem(.fixed(80)),
                        GridItem(.fixed(80)),
                        GridItem(.fixed(80)),
                        GridItem(.fixed(80))
                    ]) {
                        ForEach(levelsManager.levels, id: \.id) { level in
                            if levelsManager.isLevelUnlocked(id: level.id) {
                                NavigationLink(destination: LeveledGameView(level: level.id)
                                    .environmentObject(userConfig)
                                    .navigationBarBackButtonHidden(true)
                                    .environmentObject(levelsManager)) {
                                        ZStack {
                                            Image("level_background")
                                            VStack(spacing: 0) {
                                                Text("\(level.id)")
                                                    .font(.custom("GrandstanderRoman-Black", size: 32))
                                                    .foregroundColor(.white)
                                                Text("LVL")
                                                    .font(.custom("GrandstanderRoman-Black", size: 15))
                                                    .foregroundColor(.white)
                                            }
                                            .padding(.vertical)
                                        }
                                }
                            } else {
                                ZStack {
                                    Image("unactive_level_background")
                                    VStack(spacing: 0) {
                                        Text("\(level.id)")
                                            .font(.custom("GrandstanderRoman-Black", size: 32))
                                            .foregroundColor(.white)
                                        Text("LVL")
                                            .font(.custom("GrandstanderRoman-Black", size: 15))
                                            .foregroundColor(.white)
                                    }
                                    .padding(.vertical)
                                }
                                .opacity(0.5)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                Spacer()
                
                NavigationLink(destination: EndlessGameView()
                    .environmentObject(userConfig)
                    .navigationBarBackButtonHidden(true)
                    .environmentObject(levelsManager)) {
                    Image("play_btn")
                }
                Spacer()
            }
            .background(
                Image("main_menu_bg")
                    .resizable()
                    .frame(minWidth: UIScreen.main.bounds.width,
                           minHeight: UIScreen.main.bounds.height)
                    .ignoresSafeArea()
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ContentView()
}
