import Foundation

class LevelsManager: ObservableObject {
    @Published var levels: [Level]
    
    private let levelsKey = "unlockedLevels"
    
    init() {
        if let savedLevels = UserDefaults.standard.object(forKey: levelsKey) as? Data {
            let decoder = JSONDecoder()
            if let loadedLevels = try? decoder.decode([Level].self, from: savedLevels) {
                self.levels = loadedLevels
                return
            }
        }
        
        self.levels = (1...8).map { Level(id: $0, isUnlocked: $0 == 1) } // First level unlocked by default
    }
    
    func unlockLevel(id: Int) {
        if let index = levels.firstIndex(where: { $0.id == id }) {
            levels[index].isUnlocked = true
            saveLevels()
        }
    }
    
    func isLevelUnlocked(id: Int) -> Bool {
        if let level = levels.first(where: { $0.id == id }) {
            return level.isUnlocked
        }
        return false
    }
    
    private func saveLevels() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(levels) {
            UserDefaults.standard.set(encoded, forKey: levelsKey)
        }
    }
}

struct Level: Identifiable, Codable {
    let id: Int
    var isUnlocked: Bool
}
