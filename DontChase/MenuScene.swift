import SpriteKit

class MenuScene: SKScene {
    
    override func didMove(to view: SKView) {
        setupMenu()
    }
    
    func setupMenu() {
        let titleLabel = SKLabelNode(text: "Dont Chase")
        titleLabel.fontSize = 40
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - 100)
        addChild(titleLabel)
        
        let playButton = SKLabelNode(text: "Play")
        playButton.name = "play"
        playButton.fontSize = 30
        playButton.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(playButton)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let node = atPoint(location)
            
            if node.name == "play" {
                transitionToGameScene()
            }
        }
    }
    
    func transitionToGameScene() {
        if let view = self.view {
            let transition = SKTransition.fade(withDuration: 0.5)
            let gameScene = GameScene(size: view.bounds.size)
            gameScene.scaleMode = .aspectFill
            view.presentScene(gameScene, transition: transition)
        }
    }
}
