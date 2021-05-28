//
//  GameScene.swift
//  Healthy Rush
//
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //MARK: - Properties
    var ground: SKSpriteNode!
    var player: SKSpriteNode!
    var playerRunningFrames = [SKTexture]()
    var playerJumpingFrames = [SKTexture]()
    var cameraNode = SKCameraNode()
    var obstacles = [SKSpriteNode]()
    var jewel: SKSpriteNode!
    
    // For the scene movement
    var cameraMovePointPerSecond: CGFloat = 400.0 // Scene Speed
    var lastUpdateTime: TimeInterval = 0.0
    var dt: TimeInterval = 0.0
    
    // Settings
    var isTimeMaxObstacle: CGFloat = 8.5 // Max spawn time
    var isTimeMinObstacle: CGFloat = 3.5 // Min spawn time
    var isTimeMaxJewel: CGFloat = 7.0 // Max spawn time
    var isTimeMinJewel: CGFloat = 3.0 // Min spawn time
    var timePerFramePlayerRun: TimeInterval = 0.075 // Animation speed
    var timePerFrameJewelAnimation: TimeInterval = 0.15 // Animation speed
    var playerSelectedName = UserDefaults.standard.object(forKey: "PlayerSelected") as? String // Optional name
    var playerSelectedRunIndex = 10 // the max index of the run animation
    var playerSelectedJumpIndex = 10 // the max index of the jump animation
    var maxIndexObstacles = 6 // obstacle-index for setupObstacle
    var maxIndexBlocks = 3 // block-index for setupObstacle
    var groundSelected = Int.random(in: 1...4) // ground selected randomly

    // Don't touch
    var onGround = true
    var velocityY: CGFloat = 0.0
    var gravity: CGFloat = 0.6
    var playerPosY: CGFloat = 0.0
    
    // In-game utilities
    var numScore: Int = 0
    var gameOver = false
    var life: Int = 3
    
    // Add labels, icons and buttons
    var lifeNodes: [SKSpriteNode] = []
    var scoreLbl = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
    var jewelIcon: SKSpriteNode!
    var pauseNode: SKSpriteNode!
    var containerNode = SKNode()
    
    // Sounds
    var soundJewel = SKAction.playSoundFileNamed("diamond.wav")
    var soundJewelDrop = SKAction.playSoundFileNamed("diamondLost.wav")
    var soundJump = SKAction.playSoundFileNamed("jump.wav")
    var soundCollision = SKAction.playSoundFileNamed("collision.wav")
    
    var playableRect: CGRect {
        let ratio: CGFloat
        switch UIScreen.main.nativeBounds.height {
        case 2688, 1792, 2436:
            ratio = 2.16
        default:
            ratio = 16/9
        }
        let playableHeight = size.width / ratio
        let playableMargin = (size.height - playableHeight) / 2.0
        
        return CGRect(x: 0.0, y: playableMargin, width: size.width, height: playableHeight)
    }
    
    var cameraRect: CGRect {
        let width = playableRect.width
        let height = playableRect.height
        let x = cameraNode.position.x - size.width/2.0 + (size.width - width)/2.0
        let y = cameraNode.position.y - size.height/2.0 + (size.height - height)/2.0
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    //MARK: - Systems
    override func didMove(to view: SKView) {
        // Prevent lock
        UIApplication.shared.isIdleTimerDisabled = true
        // Update the maxIndex for the animations
        if playerSelectedName! == "TheBoy" {
            playerSelectedRunIndex = 15
            playerSelectedJumpIndex = 15
        } else if playerSelectedName! == "CuteGirl" {
            playerSelectedRunIndex = 20
            playerSelectedJumpIndex = 30
        }
        // Setup all nodes
        setupNodes()
        // Save this for the gameover
        UserDefaults.standard.setValue(groundSelected, forKey: "groundSelectedKey")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return } // we focus only on the first touch
        let node = atPoint(touch.location(in: self)) // get the node touched
        
        if node.name == "pause" {
            run(SKAction.playSoundFileNamed("buttonSound.wav"))
            if isPaused { return }
            createPanel()
            // let's stop the scene movement
            lastUpdateTime = 0.0
            dt = 0.0
            isPaused = true
        } else if node.name == "resume" {
            containerNode.removeFromParent()
            isPaused = false
            run(SKAction.playSoundFileNamed("buttonSound.wav"))
        } else if node.name == "quit" {
            isPaused = false
            run(SKAction.playSoundFileNamed("buttonSound.wav"))
            let scene = MainMenu(size: size)
            scene.scaleMode = scaleMode
            view!.presentScene(scene, transition: .doorsCloseVertical(withDuration: 0.8))
        } else {
            // Jump Touch
            if !isPaused {
                if onGround {
                    playerRunAnimationStop()
                    playerJumpAnimationStart()
                    onGround = false
                    velocityY = -25.0 // player jump to height of 25pt
                    run(soundJump) // jump sound
                }
            }
        }
    }
    
    // In order to introduce a tinier jump
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if velocityY < -12.5 {
            velocityY = -12.5
        }
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        moveCamera()
        movePlayer()
        
        if onGround && !isPaused && appDI.jump {
                 playerRunAnimationStop()
                 playerJumpAnimationStart()
                 onGround = false
                 velocityY = -25.0 // player jump to height of 25pt
                 run(soundJump) // jump sound
        }
        
        if !onGround { // The gravity will let the player fall
            velocityY += gravity
            player.position.y -= velocityY
        }
        
        if player.position.y - playerPosY < -0.00005 { // When on ground
            // this delta is needed to prevent a bug where the player was upper than the ground without sense
            playerJumpAnimationStop()
            playerRunAnimationStart()
            player.position.y = playerPosY
            velocityY = 0.0
            onGround = true
            appDI.jump = false
        }
        
        if gameOver {
            ScoreGenerator.sharedInstance.setScore(numScore) // save the last score
            let highscore = ScoreGenerator.sharedInstance.getHighscore()
            if numScore > highscore {
                ScoreGenerator.sharedInstance.setHighscore(numScore)
            }
            let scene = GameOver(size: size)
            scene.scaleMode = scaleMode
            view!.presentScene(scene, transition: .doorsCloseVertical(withDuration: 0.8))
        }
        
        boundCheckPlayer() // if he touches the left bound of the screen
    }
}

//MARK: - Configurations
extension GameScene {
    
    func setupNodes() {
        createBG()
        createGround()
        createPlayer()
        setupPhysics()
        setupLife()
        setupScore()
        setupPause()
        setupCamera()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.setupObstacles()
            self.spawnObstacles()
            self.setupJewel()
            self.spawnJewel()
        }
    }
    
    func setupPhysics() {
        physicsWorld.contactDelegate = self
    }
    
    func createBG() {
       for i in 0...2 {
           let bg = SKSpriteNode(imageNamed: "game_background_\(groundSelected)")
           bg.name = "BG"
           bg.anchorPoint = .zero
           bg.position = CGPoint(x: CGFloat(i) * bg.frame.width + 120.0 * CGFloat(i), y: 0.0)
           bg.size = self.size
           bg.zPosition = -1.0
           addChild(bg)
        }
    }
    
    func createGround() {
        for i in 0...2 {
            ground = SKSpriteNode(imageNamed: "game_ground_\(groundSelected)")
            ground.name = "Ground"
            ground.anchorPoint = .zero
            ground.zPosition = 1.0
            ground.position = CGPoint(x: -CGFloat(i)*ground.frame.width,
                                      y: appDI.isX ? 100.0 : 0.0)
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody!.isDynamic = false
            ground.physicsBody!.affectedByGravity = false
            ground.physicsBody!.categoryBitMask = PhysicsCategory.Ground
            addChild(ground)
        }
    }
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "\(playerSelectedName!)/Run (1)")
        player.name = "Player"
        if groundSelected == 3 { // darker background
            let darker = SKAction.colorize(with: .black, colorBlendFactor: 0.2, duration: 0.0)
            player.run(darker)
        }
        player.zPosition = 5.0
        player.setScale(0.4)
        player.position = CGPoint(x: frame.width/2.0, y: ground.frame.maxY + player.frame.height/2.0)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.restitution = 0.0
        player.physicsBody!.allowsRotation = false
        player.physicsBody!.categoryBitMask = PhysicsCategory.Player
        player.physicsBody!.contactTestBitMask = PhysicsCategory.Block | PhysicsCategory.Obstacle | PhysicsCategory.Jewel
        playerPosY = player.position.y
        addChild(player)
        playerRunAnimationStart()
    }
    
    func playerRunAnimationStart() {
        // If empty the texture array will be filled up
        if playerRunningFrames.isEmpty {
            for i in 1...playerSelectedRunIndex {
                let frameName = "\(playerSelectedName!)/Run (\(i))"
                playerRunningFrames.append(SKTexture(imageNamed: frameName))
            }
        }
        // Animation activated
        player.run(SKAction.repeatForever(SKAction.animate(with: playerRunningFrames, timePerFrame: timePerFramePlayerRun)), withKey: "playerRun")
    }
    
    func playerRunAnimationStop() {
        player.removeAction(forKey: "playerRun")
    }
    
    func playerJumpAnimationStart() {
        // If empty the texture array will be filled up
        if playerJumpingFrames.isEmpty {
            for i in 1...playerSelectedJumpIndex {
                let frameName = "\(playerSelectedName!)/Jump (\(i))"
                playerJumpingFrames.append(SKTexture(imageNamed: frameName))
            }
        }
        // Animation activated
        player.run((SKAction.animate(with: playerJumpingFrames, timePerFrame: 0.06)), withKey: "playerJump")
    }
    
    func playerJumpAnimationStop() {
        player.removeAction(forKey: "playerJump")
    }
    
    func setupCamera() {
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
    }
    
    func moveCamera() {
        let amountToMove = CGPoint(x: cameraMovePointPerSecond * CGFloat(dt), y: 0.0) // s = v * t
        cameraNode.position += amountToMove
        
        // Background - we use this function to loop over all sprites called BG
        enumerateChildNodes(withName: "BG") { (node, _) in
            let node = node as! SKSpriteNode
            if node.position.x + node.frame.width < self.cameraRect.origin.x {
                node.position = CGPoint(x: node.position.x
                                            + node.frame.width * 2.0, y: node.position.y)
            }
        }
        
        // Ground - we use this function to loop over all sprites called Ground
        enumerateChildNodes(withName: "Ground") { (node, _) in
            let node = node as! SKSpriteNode
            if node.position.x + node.frame.width < self.cameraRect.origin.x {
                node.position = CGPoint(x: node.position.x
                                            + node.frame.width * 2.0, y: node.position.y)
            }
        }
    }
    
    func movePlayer() {
        let amountToMove = cameraMovePointPerSecond * CGFloat(dt) // s = v * t
        player.position.x += amountToMove
    }
    
    func setupObstacles() {
        // Load the obstacles in an array
        for i in 1...maxIndexBlocks {
            let sprite = SKSpriteNode(imageNamed: "block-\(i)")
            sprite.name = "Block"
            if i == 3 && groundSelected == 3 { // tree darker due to the background
                let darker = SKAction.colorize(with: .black, colorBlendFactor: 0.2, duration: 0.0)
                sprite.run(darker)
            }
            obstacles.append(sprite)
        }
        
        for i in 1...maxIndexObstacles {
            let sprite = SKSpriteNode(imageNamed: "obstacle-\(i)")
            sprite.name = "Obstacle"
            obstacles.append(sprite)
        }
        // Set the properties of a obstacle
        let index = Int(arc4random_uniform(UInt32(obstacles.count - 1)))
        let sprite = obstacles[index].copy() as! SKSpriteNode
        sprite.zPosition = 5.0
        sprite.setScale(0.8)
        sprite.position = CGPoint(x: cameraRect.maxX + sprite.frame.width/2.0, y: ground.frame.maxY + sprite.frame.height/2.0)
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody!.affectedByGravity = false
        sprite.physicsBody!.isDynamic = false
        
        if sprite.name == "Block" {
            sprite.physicsBody!.categoryBitMask = PhysicsCategory.Block
        } else {
            sprite.physicsBody!.categoryBitMask = PhysicsCategory.Obstacle
        }
        
        sprite.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        addChild(sprite)
        // After 10.0 seconds the obstacle will be removed otherwise it will come back
        sprite.run(.sequence([.wait(forDuration: 10.0),.removeFromParent()]))
    }
    
    func spawnObstacles() {
        // An obstacle will spawn after a time between isTimeMinObstacle and isTimeMaxObstacle
        let random = Double(CGFloat.random(min: isTimeMinObstacle, max: isTimeMaxObstacle))
        run(.repeatForever(.sequence([
            .wait(forDuration: random),
            .run {
                [weak self] in  // weak used for save memory
                self?.setupObstacles()
            }
        ])))
        
        run(.repeatForever(.sequence([
            .wait(forDuration: 5.0),  // every 5 seconds the game will be harder
            .run {
                self.isTimeMaxObstacle -= 0.05
                if self.isTimeMaxObstacle <= self.isTimeMinObstacle {
                    self.isTimeMaxObstacle = self.isTimeMinObstacle
                }
            }
        ])))
    }
    
    func setupJewel() { // Similar to adding Obstacles node
        jewel = SKSpriteNode(imageNamed: "jewel/0")
        jewel.name = "Jewel"
        jewel.zPosition = 20.0
        jewel.setScale(0.95)
        let jewelHeight = jewel.frame.height
        let random = CGFloat.random(min: -jewelHeight, max: jewelHeight * 2.0)
        jewel.position = CGPoint(x: cameraRect.maxX + jewel.frame.width, y: size.height/2.0 + random)
        jewel.physicsBody = SKPhysicsBody(circleOfRadius: jewel.size.width/2.0)
        jewel.physicsBody!.affectedByGravity = false
        jewel.physicsBody!.isDynamic = false
        jewel.physicsBody!.categoryBitMask = PhysicsCategory.Jewel
        jewel.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        addChild(jewel)
        jewel.run(.sequence([.wait(forDuration: 15.0), .removeFromParent()]))
        
        // Add Animations
        var textures: [SKTexture] = []
        for i in 0...5 {
            textures.append(SKTexture(imageNamed: "jewel/\(i)"))
        }
        jewel.run(.repeatForever(.animate(with: textures, timePerFrame: timePerFrameJewelAnimation)))
    }
    
    func spawnJewel() {
        let random = CGFloat.random(min: isTimeMinJewel, max: isTimeMaxJewel)
        var bonusJewel = 0 // to introduce the possibility of getting more jewel in row
        
        run(.repeatForever(.sequence([
            .wait(forDuration: TimeInterval(random)),
            .run {
                [weak self] in
                self?.setupJewel()
                bonusJewel = Int.random(in: 1...20)
                if bonusJewel == 3 { // 5% chance of getting 3 jewel spawn
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        self?.setupJewel()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                        self?.setupJewel()
                    }
                } else if bonusJewel < 3 { // 10% chance of getting 2 jewel spawn
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        self?.setupJewel()
                    }
                }
            }
        ])))
    }
    
    func setupLife() {
        let node1 = SKSpriteNode(imageNamed: "life-on")
        let node2 = SKSpriteNode(imageNamed: "life-on")
        let node3 = SKSpriteNode(imageNamed: "life-on")
        setupLifePos(node1, i: 1.0, j: 0.0)
        setupLifePos(node2, i: 2.0, j: 8.0)
        setupLifePos(node3, i: 3.0, j: 16.0)
        lifeNodes.append(node1)
        lifeNodes.append(node2)
        lifeNodes.append(node3)
    }
    
    func setupLifePos(_ node: SKSpriteNode, i: CGFloat, j: CGFloat) {
        let width = playableRect.width
        let height = playableRect.height
        node.setScale(0.5)
        node.zPosition = 50.0
        node.position = CGPoint(x: -width/2.0 + node.frame.width * i + j - 15.0,
                                y: height/2.0 - node.frame.height/2.0)
        cameraNode.addChild(node)
    }
    
    func setupScore() {
        // Icon
        jewelIcon = SKSpriteNode(imageNamed: "jewel/0")
        jewelIcon.setScale(0.6)
        jewelIcon.zPosition = 50.0
        jewelIcon.position = CGPoint(x: -playableRect.width/2.0 + jewelIcon.frame.width, y: playableRect.height/2.0 - lifeNodes[0].frame.height - jewelIcon.frame.height/2.0)
        cameraNode.addChild(jewelIcon)
        
        // Score Label
        scoreLbl.text = "\(numScore)"
        scoreLbl.fontSize = 60.0
        scoreLbl.horizontalAlignmentMode = .left
        scoreLbl.verticalAlignmentMode = .top
        scoreLbl.zPosition = 50.0
        scoreLbl.position = CGPoint(x: -playableRect.width/2.0 + jewelIcon.frame.width * 2.0 - 10.0,
                                    y: jewelIcon.position.y + jewelIcon.frame.height/2.0 - 8.0)
        cameraNode.addChild(scoreLbl)
    }
    
    func setupPause() {
        pauseNode = SKSpriteNode(imageNamed: "pause")
        pauseNode.setScale(0.625)
        pauseNode.zPosition = 50.0
        pauseNode.name = "pause"
        pauseNode.position = CGPoint(x: playableRect.width/2.0 - pauseNode.frame.width/2.0 - 30.0,
                                     y: playableRect.height/2.0 - pauseNode.frame.height/2.0 - 10.0)
        cameraNode.addChild(pauseNode)
    }
    
    func createPanel() {
        cameraNode.addChild(containerNode)
        // Add the pause menu
        let panel = SKSpriteNode(imageNamed: "panel")
        panel.zPosition = 60.0
        panel.position = .zero
        containerNode.addChild(panel)
        // Add resume button
        let resume = SKSpriteNode(imageNamed: "resume")
        resume.zPosition = 70.0
        resume.name = "resume"
        resume.setScale(0.875)
        resume.position = CGPoint(x: -panel.frame.width/2.0 + resume.frame.width * 1.5,
                                  y: 0.0)
        panel.addChild(resume)
        // Add back button
        let quit = SKSpriteNode(imageNamed: "back")
        quit.zPosition = 70.0
        quit.name = "quit"
        quit.setScale(0.875)
        quit.position = CGPoint(x: panel.frame.width/2.0 - quit.frame.width * 1.5,
                                  y: 0.0)
        panel.addChild(quit)
    }
    
    func boundCheckPlayer() {
        // Check that the player touches the screen border
        let bottomLeft = CGPoint(x: cameraRect.minX, y: cameraRect.minY)
        if player.position.x <= bottomLeft.x {
            player.position.x = bottomLeft.x
            lifeNodes.forEach({ $0.texture = SKTexture(imageNamed: "life-off") })
            gameOver = true
        }
    }
    
    func setupGameOver() {
        life -= 1
        if life <= 0 { life = 0}
        lifeNodes[life].texture = SKTexture(imageNamed: "life-off")
        
        if life <= 0 && !gameOver {
            gameOver = true
        }
    }
}

//MARK: - SKPhysicsContactDelegate
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask == PhysicsCategory.Player ? contact.bodyB : contact.bodyA
        
        switch other.categoryBitMask {
            case PhysicsCategory.Block:
                cameraMovePointPerSecond += 50  // if hit the game will be harder
                // Drop animation
                if numScore > 0 {
                    let jewelDropped = SKSpriteNode(imageNamed: "jewel/0")
                    jewelDropped.name = "JewelDropped"
                    jewelDropped.zPosition = 20.0
                    jewelDropped.setScale(0.95)
                    let jewelHeight = jewelDropped.frame.height
                    jewelDropped.position = CGPoint(x: player.position.x - jewelDropped.frame.width, y: player.position.y + jewelHeight)
                    jewelDropped.physicsBody = SKPhysicsBody(circleOfRadius: jewelDropped.size.width/2.0)
                    jewelDropped.physicsBody?.affectedByGravity = true
                    jewelDropped.physicsBody?.categoryBitMask = UInt32(0) // no collision
                    jewelDropped.physicsBody?.restitution = CGFloat(1.0)
                    addChild(jewelDropped)
                    run(soundJewelDrop) // sound drop jewel
                    jewelDropped.run(.sequence([.wait(forDuration: 3.0), .removeFromParent()]))
                }
                // Update Score and run sound
                numScore -= 1 // you lose a jewel
                if numScore <= 0 { numScore = 0 }
                scoreLbl.text = "\(numScore)"
        
            case PhysicsCategory.Obstacle:
                setupGameOver()
                run(soundCollision) // collision sound
        
            case PhysicsCategory.Jewel:
                if let node = other.node {
                    node.removeFromParent()
                    numScore += 1
                    scoreLbl.text = "\(numScore)"
                    if numScore % 5 == 0 {
                        cameraMovePointPerSecond += 25 // every 5 jewela the game will be harder
                    }
                    // Play jewel sound if possible
                    run(soundJewel)
                }
            default: break
        }
    }
}
