import SpriteKit

class GameScene: SKScene {
    
    let player = SKSpriteNode(imageNamed: "player")
    var playerPath: [SKSpriteNode] = []
    var enemies: [SKSpriteNode] = []
    var playerLives = 3
    var gameTime = 0
    var gameTimer: Timer!
    var spawnTimer: Timer!
    
    override func didMove(to view: SKView) {
        setupScene()
    }
    
    func setupScene() {
        createBackground()
        setupPlayer()
        startGame()
    }
    
    func createBackground() {
        let backgroundTexture = SKTexture(imageNamed: "background")
        let backgroundNode = SKSpriteNode(texture: backgroundTexture)
        
        let rows = Int(size.height / 32) + 1
        let columns = Int(size.width / 32) + 1
        
        for row in 0..<rows {
            for column in 0..<columns {
                let node = backgroundNode.copy() as! SKSpriteNode
                node.size = CGSize(width: 32, height: 32)
                node.position = CGPoint(x: CGFloat(column) * 32, y: CGFloat(row) * 32)
                node.zPosition = -1
                addChild(node)
            }
        }
    }
    
    func setupPlayer() {
        player.size = CGSize(width: 64, height: 64)
        player.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(player)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let previousLocation = touch.previousLocation(in: self)
            let moveVector = CGVector(dx: location.x - previousLocation.x, dy: location.y - previousLocation.y)
            player.position = CGPoint(x: player.position.x + moveVector.dx, y: player.position.y + moveVector.dy)
            leaveGasTrail(at: player.position)
        }
    }
    
    func leaveGasTrail(at position: CGPoint) {
        let gas = SKSpriteNode(imageNamed: "gas")
        gas.size = CGSize(width: 32, height: 32)
        gas.position = position
        addChild(gas)
        
        playerPath.append(gas)
        
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeOut, remove])
        gas.run(sequence) {
            if let index = self.playerPath.firstIndex(of: gas) {
                self.playerPath.remove(at: index)
            }
        }
    }
    
    func startGame() {
        playerLives = 3
        gameTime = 0
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateGameTime), userInfo: nil, repeats: true)
        spawnTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(spawnEnemy), userInfo: nil, repeats: true)
        
        print("Game started")
    }
    
    @objc func updateGameTime() {
        gameTime += 1
        print("Game time: \(gameTime) seconds")
    }
    
    @objc func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.size = CGSize(width: 64, height: 64)
        
        // Spawning the enemy at a random position on the screen
        let xPos = CGFloat.random(in: 0...size.width)
        let yPos = CGFloat.random(in: 0...size.height)
        enemy.position = CGPoint(x: xPos, y: yPos)
        
        addChild(enemy)
        enemies.append(enemy)
        
        // Make the enemy follow the player
        let moveAction = SKAction.run { [weak self, weak enemy] in
            guard let self = self, let enemy = enemy else { return }
            let dx = self.player.position.x - enemy.position.x
            let dy = self.player.position.y - enemy.position.y
            let angle = atan2(dy, dx)
            let speed: CGFloat = 50.0 // Reduzindo a velocidade do inimigo
            let vx = cos(angle) * speed
            let vy = sin(angle) * speed
            enemy.position = CGPoint(x: enemy.position.x + vx * CGFloat(self.frame.size.width/1000), y: enemy.position.y + vy * CGFloat(self.frame.size.height/1000))
        }
        
        let followAction = SKAction.repeatForever(SKAction.sequence([moveAction, SKAction.wait(forDuration: 0.05)]))
        enemy.run(followAction)
        
        print("Spawned enemy at position: \(enemy.position)")
    }
    
    override func update(_ currentTime: TimeInterval) {
        for enemy in enemies {
            if player.frame.intersects(enemy.frame) {
                playerLives -= 1
                enemy.removeFromParent()
                enemies.removeAll { $0 == enemy }
                print("Player hit by enemy. Lives left: \(playerLives)")
                if playerLives == 0 {
                    gameOver()
                }
            }
            
            for gas in playerPath {
                if gas.frame.intersects(enemy.frame) {
                    enemy.removeFromParent()
                    enemies.removeAll { $0 == enemy }
                    gas.removeFromParent()
                    playerPath.removeAll { $0 == gas }
                    print("Enemy hit by gas and destroyed")
                }
            }
        }
    }
    
    func gameOver() {
        gameTimer.invalidate()
        spawnTimer.invalidate()
        
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontSize = 40
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(gameOverLabel)
        
        let timeSurvivedLabel = SKLabelNode(text: "Time Survived: \(gameTime)")
        timeSurvivedLabel.fontSize = 20
        timeSurvivedLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        addChild(timeSurvivedLabel)
        
        let restartButton = SKLabelNode(text: "Restart")
        restartButton.name = "restart"
        restartButton.fontSize = 30
        restartButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 100)
        addChild(restartButton)
        
        print("Game over. Time survived: \(gameTime) seconds")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let node = atPoint(location)
            
            if node.name == "restart" {
                print("Restart button pressed")
                removeAllChildren()
                enemies.removeAll()
                playerPath.removeAll()
                setupScene()
            }
        }
    }
}
