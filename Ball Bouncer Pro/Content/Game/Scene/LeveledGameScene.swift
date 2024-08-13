
import SwiftUI
import SpriteKit

class LeveledGameScene: SKScene, SKPhysicsContactDelegate {
    
    var level: Int
    private var levelLabel: SKLabelNode
    
    private var pauseButton: SKSpriteNode = SKSpriteNode(imageNamed: "pause_btn")
    
    private var backgroundImage: SKSpriteNode {
        get {
            let node = SKSpriteNode(imageNamed: "screen_bg")
            node.size = size
            node.position = CGPoint(x: size.width / 2, y: size.height / 2)
            return node
        }
    }
    
    init(level: Int) {
        self.level = level
        levelLabel = SKLabelNode(text: "LVL:\(level)")
        super.init(size: CGSize(width: 1000, height: 1835))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var balanceLabel: SKLabelNode = SKLabelNode(text: "0")
    private var balance: Int = UserDefaults.standard.integer(forKey: "credits") {
        didSet {
            UserDefaults.standard.set(balance, forKey: "credits")
            balanceLabel.text = "\(balance)"
        }
    }
    
    private var touchesObjective = 0
    private var ballPlatformTouchesCount = 0 {
        didSet {
            ballPlatformTouchesLabel.text = "\(ballPlatformTouchesCount)/\(touchesObjective)"
            if ballPlatformTouchesCount == touchesObjective {
                winAction()
            }
        }
    }
    
    private var ballPlatformTouchesLabel: SKLabelNode = SKLabelNode(text: "0/16")
    
    private var platform: SKSpriteNode = SKSpriteNode(imageNamed: "platform_not_active")
    private var ball = SKSpriteNode(imageNamed: UserDefaults.standard.string(forKey: "selectedBall") ?? "ball_first")
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        setUpAvailableObstacles()
        addChild(backgroundImage)
        touchesObjective = 16 + (level * 2)
        
        pauseButton.position = CGPoint(x: size.width - 100, y: size.height - 170)
        pauseButton.size = CGSize(width: 160, height: 120)
        pauseButton.name = "pause_button"
        addChild(pauseButton)
        
        levelLabel.fontName = "GrandstanderRoman-Black"
        levelLabel.fontSize = 62
        levelLabel.fontColor = .white
        levelLabel.position = CGPoint(x: 480, y: size.height - 190)
        levelLabel.zPosition = 5
        addChild(levelLabel)
        
        ballPlatformTouchesLabel = .init(text: "0/\(touchesObjective)")
        ballPlatformTouchesLabel.fontName = "GrandstanderRoman-Black"
        ballPlatformTouchesLabel.fontSize = 62
        ballPlatformTouchesLabel.fontColor = .white
        ballPlatformTouchesLabel.position = CGPoint(x: 670, y: size.height - 190)
        ballPlatformTouchesLabel.zPosition = 5
        addChild(ballPlatformTouchesLabel)
        
        let platformMoveZone = SKSpriteNode(imageNamed: "platform_move_zone")
        platformMoveZone.position = CGPoint(x: size.width / 2, y: 150)
        platformMoveZone.size = CGSize(width: size.width - 100, height: 50)
        addChild(platformMoveZone)
        
        platform.position = CGPoint(x: size.width / 2, y: 150)
        platform.size = CGSize(width: 250, height: 100)
        platform.name = "platform"
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.categoryBitMask = 2
        platform.physicsBody?.collisionBitMask = 1
        platform.physicsBody?.contactTestBitMask = 1
        addChild(platform)
        
        ball.position = CGPoint(x: size.width / 2, y: size.height - 300)
        ball.size = CGSize(width: 82, height: 78)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.height / 2)
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.affectedByGravity = false
        ball.physicsBody?.categoryBitMask = 1
        ball.physicsBody?.collisionBitMask = 2 | 3 | 4
        ball.physicsBody?.contactTestBitMask = 2 | 3 | 4
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.allowsRotation = true
        ball.name = "ball"
        addChild(ball)
        
        createBalanceLabel()
        
        createInvisibleItems()
        
        createFirstScreen()
    }
    
    func accelerateBall(body: SKPhysicsBody) {
        // Увеличиваем скорость мяча
        let currentVelocity = body.velocity
        let accelerationFactor: CGFloat = 1.2
        let newVelocity = CGVector(dx: currentVelocity.dx * accelerationFactor, dy: currentVelocity.dy * accelerationFactor)
        body.velocity = newVelocity
    }
    
    private var firstScreenNode: SKSpriteNode!
    
    private func createFirstScreen() {
        firstScreenNode = SKSpriteNode()
        let backgroundBlack = SKSpriteNode(color: .black.withAlphaComponent(0.4), size: size)
        backgroundBlack.zPosition = 4
        backgroundBlack.position = CGPoint(x: size.width / 2, y: size.height / 2)
        firstScreenNode.addChild(backgroundBlack)
        
        let startPlayGameButton = SKSpriteNode(imageNamed: "start_game")
        startPlayGameButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 250)
        startPlayGameButton.size = CGSize(width: 240, height: 170)
        startPlayGameButton.name = "startPlayGameButton"
        startPlayGameButton.zPosition = 5
        firstScreenNode.addChild(startPlayGameButton)
        
        let tutorTitleFirst = SKLabelNode(text: "Move the platform to")
        tutorTitleFirst.fontName = "GrandstanderRoman-Black"
        tutorTitleFirst.fontSize = 62
        tutorTitleFirst.fontColor = .white
        tutorTitleFirst.position = CGPoint(x: size.width / 2, y: size.height / 2 + 350)
        tutorTitleFirst.zPosition = 5
        firstScreenNode.addChild(tutorTitleFirst)
        
        let tutorTitleSecond = SKLabelNode(text: "push the ball")
        tutorTitleSecond.fontName = "GrandstanderRoman-Black"
        tutorTitleSecond.fontSize = 62
        tutorTitleSecond.fontColor = .white
        tutorTitleSecond.position = CGPoint(x: size.width / 2, y: size.height / 2 + 280)
        tutorTitleSecond.zPosition = 5
        firstScreenNode.addChild(tutorTitleSecond)
        
        addChild(firstScreenNode)
    }
    
    private var availableObstacles = ["obstacle_one"]
    private var nowSpawnedCoins = 0
    private var claimedCoinsNow = 0 {
        didSet {
            if claimedCoinsNow == nowSpawnedCoins {
                spawnCoins()
            }
        }
    }
    private var obstaclesNode: [SKNode] = []
    
    private func createObstacles() {
        for i in 1...4 {
            let startY: CGFloat = 300 * CGFloat(i) + CGFloat.random(in: 50...100)
            let startX = CGFloat.random(in: 100...size.width - 100)
            let name = availableObstacles.randomElement() ?? "obstacle_one"
            let node = SKSpriteNode(imageNamed: name)
            node.position = CGPoint(x: startX, y: startY)
            node.size = CGSize(width: node.size.width * 2.5, height: node.size.height * 2.5)
            node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
            node.physicsBody?.isDynamic = false
            node.physicsBody?.affectedByGravity = false
            node.physicsBody?.categoryBitMask = 3
            node.physicsBody?.collisionBitMask = 1
            node.physicsBody?.contactTestBitMask = 1
            node.name = name
            addChild(node)
            obstaclesNode.append(node)
            
            
        }
    }
    
    private func startObstaclesAnimations() {
        for obstacle in obstaclesNode {
            let speed = Double(Int.random(in: 2...9))
            let actionMove1 = SKAction.move(to: CGPoint(x: size.width - 100, y: obstacle.position.y), duration: speed)
            let actionMove2 = SKAction.move(to: CGPoint(x: 100, y: obstacle.position.y), duration: speed)
            var seq = SKAction.sequence([actionMove1, actionMove2])
            if Bool.random() {
                seq = SKAction.sequence([actionMove2, actionMove1])
            }
            let repeate = SKAction.repeatForever(seq)
            if obstacle.name == "obstacle_six" {
                let rotateAction = SKAction.rotate(byAngle: .pi * 2, duration: 2.0)
                let infiniteRotateAction = SKAction.repeatForever(rotateAction)
                obstacle.run(infiniteRotateAction)
            } else {
                obstacle.run(repeate)
            }
        }
    }
    
    private func spawnCoins() {
        for _ in 1...(Int.random(in: 3...6)) {
            let x = CGFloat.random(in: 100...size.width - 100)
            let y = CGFloat.random(in: 350...size.height - 350)
            let coinNode = SKSpriteNode(imageNamed: "coin")
            coinNode.size = CGSize(width: 62, height: 62)
            coinNode.position = CGPoint(x: x, y: y)
            coinNode.physicsBody = SKPhysicsBody(circleOfRadius: coinNode.size.height / 2)
            coinNode.physicsBody?.isDynamic = false
            coinNode.physicsBody?.affectedByGravity = false
            coinNode.physicsBody?.categoryBitMask = 5
            coinNode.physicsBody?.collisionBitMask = 1
            coinNode.physicsBody?.contactTestBitMask = 1
            addChild(coinNode)
            nowSpawnedCoins += 1
        }
    }
    
    private func createInvisibleItems() {
        let invisible = SKSpriteNode(color: .clear, size: CGSize(width: 1, height: size.height))
        invisible.position = CGPoint(x: 1, y: size.height / 2)
        invisible.physicsBody = SKPhysicsBody(rectangleOf: invisible.size)
        invisible.physicsBody?.isDynamic = false
        invisible.physicsBody?.affectedByGravity = false
        invisible.physicsBody?.categoryBitMask = 4
        invisible.physicsBody?.collisionBitMask = 1
        invisible.physicsBody?.contactTestBitMask = 1
        addChild(invisible)
        
        let invisible2 = SKSpriteNode(color: .clear, size: CGSize(width: 1, height: size.height))
        invisible2.position = CGPoint(x: size.width - 1, y: size.height / 2)
        invisible2.physicsBody = SKPhysicsBody(rectangleOf: invisible2.size)
        invisible2.physicsBody?.isDynamic = false
        invisible2.physicsBody?.affectedByGravity = false
        invisible2.physicsBody?.categoryBitMask = 4
        invisible2.physicsBody?.collisionBitMask = 1
        invisible2.physicsBody?.contactTestBitMask = 1
        addChild(invisible2)
        
        let invisible3 = SKSpriteNode(color: .clear, size: CGSize(width: size.width, height: 1))
        invisible3.position = CGPoint(x: size.width / 2, y: size.height - 290)
        invisible3.physicsBody = SKPhysicsBody(rectangleOf: invisible3.size)
        invisible3.physicsBody?.isDynamic = false
        invisible3.physicsBody?.affectedByGravity = false
        invisible3.physicsBody?.categoryBitMask = 4
        invisible3.physicsBody?.collisionBitMask = 1
        invisible3.physicsBody?.contactTestBitMask = 1
        addChild(invisible3)
    }
    
    private func createBalanceLabel() {
        let balanceBg = SKSpriteNode(imageNamed: "balance_bg")
        balanceBg.position = CGPoint(x: 200, y: size.height - 170)
        balanceBg.size = CGSize(width: 350, height: 120)
        balanceBg.zPosition = 5
        addChild(balanceBg)
        
        let coin = SKSpriteNode(imageNamed: "coin")
        coin.position = CGPoint(x: 300, y: size.height - 170)
        coin.size = CGSize(width: 62, height: 62)
        coin.zPosition = 6
        addChild(coin)
        
        balanceLabel = .init(text: "\(balance)")
        balanceLabel.fontName = "GrandstanderRoman-Black"
        balanceLabel.fontSize = 62
        balanceLabel.fontColor = .white
        balanceLabel.zPosition = 6
        balanceLabel.position = CGPoint(x: 150, y: size.height - 190)
        addChild(balanceLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let loc = touch.location(in: self)
            let object = atPoint(loc)
            
            if object.name == "startPlayGameButton" {
                firstScreenNode.run(SKAction.fadeOut(withDuration: 0.3)) {
                    self.firstScreenNode.removeFromParent()
                }
                ball.physicsBody?.affectedByGravity = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    self.createObstacles()
                    self.startObstaclesAnimations()
                    self.spawnCoins()
                }
            }
            
            if object.name == "pause_button" {
                pauseAction()
            }
            
            if object.name == "home_button" {
                NotificationCenter.default.post(name: Notification.Name("to_home"), object: nil)
            }
            
            if object.name == "settingsButton" {
                NotificationCenter.default.post(name: Notification.Name("to_settings"), object: nil)
            }
            
            if object.name == "restartButton" {
                let newScene = LeveledGameScene(level: level)
                view?.presentScene(newScene)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let loc = touch.location(in: self)
            let object = atPoint(loc)
            
            if object.name == "platform" {
                if loc.x > 100 && loc.x < size.width - 100 {
                    platform.position.x = loc.x
                }
            }
        }
    }
    
    private func setUpAvailableObstacles() {
        if level >= 2 {
            availableObstacles.append("obstacle_second")
            availableObstacles.append("obstacle_third")
        }
        if level >= 3 {
            availableObstacles.append("obstacle_four")
        }
        if level >= 4 {
            availableObstacles.append("obstacle_five")
        }
        if level >= 6 {
            availableObstacles.append("obstacle_six")
        }
    }
    
    private var texturePlatformNotActive = SKTexture(imageNamed: "platform_not_active")
    private var texturePlatformActive = SKTexture(imageNamed: "platform")
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactA = contact.bodyA
        let contactB = contact.bodyB
        
        if (contactA.categoryBitMask == 1 && contactB.categoryBitMask == 2) ||
            (contactA.categoryBitMask == 2 && contactB.categoryBitMask == 1) {
            
            let ballBody: SKPhysicsBody
            
            if contactA.categoryBitMask == 1 {
                ballBody = contactA
            } else {
                ballBody = contactB
            }
            
            accelerateBall(body: ballBody)
            
            let actionTexture = SKAction.setTexture(texturePlatformActive)
            let wait = SKAction.wait(forDuration: 0.3)
            let actionTexture2 = SKAction.setTexture(texturePlatformNotActive)
            let seq = SKAction.sequence([actionTexture,wait,actionTexture2])
            platform.run(seq)
            
            ballPlatformTouchesCount += 1
        }
        
        if (contactA.categoryBitMask == 1 && contactB.categoryBitMask == 5) ||
            (contactA.categoryBitMask == 5 && contactB.categoryBitMask == 1) {
            let coinBody: SKPhysicsBody
                        
            if contactA.categoryBitMask == 5 {
                coinBody = contactA
            } else {
                coinBody = contactB
            }
            
            if let node = coinBody.node {
                node.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.2), SKAction.removeFromParent()]))
                balance += 10
                claimedCoinsNow += 1
            }
        }
        
        if ((contactA.categoryBitMask == 1 && contactB.categoryBitMask == 3) ||
            (contactA.categoryBitMask == 3 && contactB.categoryBitMask == 1)) ||
            ((contactA.categoryBitMask == 1 && contactB.categoryBitMask == 4) ||
                        (contactA.categoryBitMask == 4 && contactB.categoryBitMask == 1)){
            
            let ballBody: SKPhysicsBody
            
            if contactA.categoryBitMask == 1 {
                ballBody = contactA
            } else {
                ballBody = contactB
            }
            
            accelerateBall(body: ballBody)
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        if ball.position.y < 0 {
            loseAction()
        }
    }
    
    private var loseNode: SKSpriteNode!
    private var winNode: SKSpriteNode!
    private var pauseNode: SKSpriteNode!
    
    private func loseAction() {
        if loseNode == nil {
            createLoseScreen()
        }
        addChild(loseNode)
        loseNode.run(SKAction.fadeIn(withDuration: 0.5))
        isPaused = true
    }
    
    private func winAction() {
        NotificationCenter.default.post(name: Notification.Name("win"), object: nil, userInfo: ["credits": balance])
        if winNode == nil {
            createWinScreen()
        }
        addChild(winNode)
        winNode.run(SKAction.fadeIn(withDuration: 0.5)) {
            self.isPaused = true
        }
    }
    
    private func pauseAction() {
        if pauseNode == nil {
            createPauseContent()
        }
        addChild(pauseNode)
        pauseNode.run(SKAction.fadeIn(withDuration: 0.5)) {
            self.isPaused = true
        }
    }
    
    private func createLoseScreen() {
        loseNode = SKSpriteNode()
        let backgroundBlack = SKSpriteNode(color: .black.withAlphaComponent(0.4), size: size)
        backgroundBlack.zPosition = 4
        backgroundBlack.position = CGPoint(x: size.width / 2, y: size.height / 2)
        loseNode.addChild(backgroundBlack)
        
        let defeatLabel = SKLabelNode(text: "DEFEAT")
        defeatLabel.fontName = "GrandstanderRoman-Black"
        defeatLabel.fontSize = 156
        defeatLabel.fontColor = .white
        defeatLabel.zPosition = 5
        defeatLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 200)
        loseNode.addChild(defeatLabel)
        
        let homeButton = SKSpriteNode(imageNamed: "home_button")
        homeButton.position = CGPoint(x: size.width / 2 - 220, y: size.height / 2)
        homeButton.size = CGSize(width: 200, height: 190)
        homeButton.name = "home_button"
        homeButton.zPosition = 5
        loseNode.addChild(homeButton)
        
        let restartButton = SKSpriteNode(imageNamed: "restart_button")
        restartButton.position = CGPoint(x: size.width / 2, y: size.height / 2)
        restartButton.size = CGSize(width: 200, height: 190)
        restartButton.name = "restartButton"
        restartButton.zPosition = 5
        loseNode.addChild(restartButton)
        
        let settingsButton = SKSpriteNode(imageNamed: "settings_button")
        settingsButton.position = CGPoint(x: size.width / 2 + 220, y: size.height / 2)
        settingsButton.size = CGSize(width: 200, height: 190)
        settingsButton.name = "settingsButton"
        settingsButton.zPosition = 5
        loseNode.addChild(settingsButton)
    }
    
    private func createWinScreen() {
        winNode = SKSpriteNode()
        let backgroundBlack = SKSpriteNode(color: .black.withAlphaComponent(0.4), size: size)
        backgroundBlack.zPosition = 4
        backgroundBlack.position = CGPoint(x: size.width / 2, y: size.height / 2)
        winNode.addChild(backgroundBlack)
        
        let defeatLabel = SKLabelNode(text: "WINNER!")
        defeatLabel.fontName = "GrandstanderRoman-Black"
        defeatLabel.fontSize = 156
        defeatLabel.fontColor = .white
        defeatLabel.zPosition = 5
        defeatLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 200)
        winNode.addChild(defeatLabel)
        
        let homeButton = SKSpriteNode(imageNamed: "home_button")
        homeButton.position = CGPoint(x: size.width / 2 - 110, y: size.height / 2)
        homeButton.size = CGSize(width: 200, height: 190)
        homeButton.name = "home_button"
        homeButton.zPosition = 5
        winNode.addChild(homeButton)
        
        let settingsButton = SKSpriteNode(imageNamed: "settings_button")
        settingsButton.position = CGPoint(x: size.width / 2 + 110, y: size.height / 2)
        settingsButton.size = CGSize(width: 200, height: 190)
        settingsButton.name = "settingsButton"
        settingsButton.zPosition = 5
        winNode.addChild(settingsButton)
    }
    
    private func createPauseContent() {
        pauseNode = SKSpriteNode()
        let backgroundBlack = SKSpriteNode(color: .black.withAlphaComponent(0.4), size: size)
        backgroundBlack.zPosition = 4
        backgroundBlack.position = CGPoint(x: size.width / 2, y: size.height / 2)
        pauseNode.addChild(backgroundBlack)
        
        let defeatLabel = SKLabelNode(text: "PAUSE")
        defeatLabel.fontName = "GrandstanderRoman-Black"
        defeatLabel.fontSize = 156
        defeatLabel.fontColor = .white
        defeatLabel.zPosition = 5
        defeatLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 200)
        pauseNode.addChild(defeatLabel)
        
        let homeButton = SKSpriteNode(imageNamed: "home_button")
        homeButton.position = CGPoint(x: size.width / 2 - 110, y: size.height / 2)
        homeButton.size = CGSize(width: 200, height: 190)
        homeButton.name = "home_button"
        homeButton.zPosition = 5
        pauseNode.addChild(homeButton)
        
        let restartButton = SKSpriteNode(imageNamed: "restart_button")
        restartButton.position = CGPoint(x: size.width / 2 + 110, y: size.height / 2)
        restartButton.size = CGSize(width: 200, height: 190)
        restartButton.name = "restartButton"
        restartButton.zPosition = 5
        pauseNode.addChild(restartButton)
        
        let tutorTitleFirst = SKLabelNode(text: "If u choose “home”")
        tutorTitleFirst.fontName = "GrandstanderRoman-Black"
        tutorTitleFirst.fontSize = 62
        tutorTitleFirst.fontColor = .white
        tutorTitleFirst.position = CGPoint(x: size.width / 2, y: size.height / 2 - 350)
        tutorTitleFirst.zPosition = 5
        pauseNode.addChild(tutorTitleFirst)
        
        let tutorTitleSecond = SKLabelNode(text: "game will end")
        tutorTitleSecond.fontName = "GrandstanderRoman-Black"
        tutorTitleSecond.fontSize = 62
        tutorTitleSecond.fontColor = .white
        tutorTitleSecond.position = CGPoint(x: size.width / 2, y: size.height / 2 - 420)
        tutorTitleSecond.zPosition = 5
        pauseNode.addChild(tutorTitleSecond)
    }
    
}

#Preview {
    VStack {
        SpriteView(scene: LeveledGameScene(level: 1))
            .ignoresSafeArea()
    }
}
