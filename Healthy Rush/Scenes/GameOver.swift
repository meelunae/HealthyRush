//
//  GameOver.swift
//  Healthy Rush
//
//

import SpriteKit

class GameOver: SKScene {
    //MARK: - Systems
    let groundSelected = UserDefaults.standard.object(forKey: "groundSelectedKey") as? Int // Ground selected in the opening
    
    override func didMove(to view: SKView) {
        createBGNodes()
        createGroundNodes()
        createNode()
        
        SKTAudio.sharedInstance().stopBGMusic()
        let soundGameOver = SKAction.playSoundFileNamed("gameOver.wav")
        run(soundGameOver)
        
        run(.sequence([
            .wait(forDuration: 5.0),
            .run {
                let scene = MainMenu(size: self.size)
                scene.scaleMode = self.scaleMode
                self.view!.presentScene(scene, transition: .doorsCloseVertical(withDuration: 0.5))
            }
        ]))
    }
    
    override func update(_ currentTime: TimeInterval) {
        moveNodes()
    }
}

//MARK: - Configurations
extension GameOver {
    func createBGNodes() {
       for i in 0...2 {
            let bgNode = SKSpriteNode(imageNamed: "game_background_\(groundSelected!)")
            bgNode.name = "background"
            bgNode.anchorPoint = .zero
            bgNode.position = CGPoint(x: CGFloat(i) * bgNode.frame.width + 105.0 * CGFloat(i), y: 0.0)
            bgNode.size = self.size
            bgNode.zPosition = -1.0
            addChild(bgNode)
        }
    }
    
    func createGroundNodes() {
        for i in 0...2 {
            let groundNode = SKSpriteNode(imageNamed: "game_ground_\(groundSelected!)")
            groundNode.name = "ground"
            groundNode.anchorPoint = .zero
            groundNode.zPosition = 1.0
            groundNode.position = CGPoint(x: -CGFloat(i)*groundNode.frame.width + 105.0  * CGFloat(i),                                y: appDI.isX ? 100.0 : 0.0)
            addChild(groundNode)
        }
    }
    
    func moveNodes() {
        enumerateChildNodes(withName: "background") { (node, _) in
            let node = node as! SKSpriteNode
            node.position.x -= 8.0
            
            if node.position.x < -self.frame.width {
                node.position.x += node.frame.width * 2.0
            }
        }
        
        enumerateChildNodes(withName: "ground") { (node, _) in
            let node = node as! SKSpriteNode
            node.position.x -= 8.0
            
            if node.position.x < -self.frame.width {
                node.position.x += node.frame.width * 2.0
            }
        }
    }
    
    func createNode() {
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.zPosition = 10.0
        gameOver.position = CGPoint(x: size.width/2.0,
                                y: size.height/2.0 + gameOver.frame.height/2.0)
        addChild(gameOver)
        
        let scalepUp = SKAction.scale(to: 1.1, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        let fullScale = SKAction.sequence([scalepUp, scaleDown])
        gameOver.run(.repeatForever(fullScale))
    }
}
