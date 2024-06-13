import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    var skView: SKView {
        return view as! SKView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentMenuScene()
    }
    
    func presentMenuScene() {
        let menuScene = MenuScene(size: view.bounds.size)
        menuScene.scaleMode = .aspectFill
        
        skView.presentScene(menuScene)
        
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
