import Foundation

class UserConfig: ObservableObject {
    
    var credits: Int = 0 {
        didSet {
            UserDefaults.standard.set(credits, forKey: "credits")
        }
    }
    var selectedBall: String = ""  {
        didSet {
            UserDefaults.standard.set(selectedBall, forKey: "selectedBall")
        }
    }
    
    init() {
        credits = UserDefaults.standard.integer(forKey: "credits")
        selectedBall = UserDefaults.standard.string(forKey: "selectedBall") ?? "ball_first"
    }
    
}
