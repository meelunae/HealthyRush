//
//  MainMenu.swift
//  Healthy Rush
//
//

import SpriteKit

class MainMenu: SKScene {
    
    //MARK: - Properties
    var containerNode: SKSpriteNode!
    
    // Settings
    let buttonScale: CGFloat = 1.2
    var timePerFrameTheBoyAnimations: TimeInterval = 0.095 // Animations speed
    var timePerFrameCuteGirlAnimations: TimeInterval = 0.065 // Animations speed
    var playerSelectedKey = "PlayerSelected"
    var firstOpen = true // in order to avoid bug in updatePlayerSelection()
    let selectionLbl = SKLabelNode(fontNamed: "AmericanTypewriter-Bold") // selection label
    
    // For the info panel
    var currInfoPageNum : Int = 1
    var pageInfoNum : Int = 3
    var istanceInfoActive : Bool = false
    
    //MARK: - Systems
    override func didMove(to view: SKView) {
        setupBG()
        setupNodes()
        setupPlayer()
        SKTAudio.sharedInstance().playBGMusic("backgroundMusic.mp3") // play bg music
        if UserDefaults.standard.object(forKey: "PlayerSelected") == nil { // first time setting
            UserDefaults.standard.setValue("TheBoy", forKey: playerSelectedKey)
        }
        setupSelectionLabel()
        updatePlayerSelection()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let node = atPoint(touch.location(in: self))
        
        if node.name == "play" {
            run(SKAction.playSoundFileNamed("buttonSound.wav"))
            let scene = GameScene(size: size)
            scene.scaleMode = scaleMode
            view!.presentScene(scene, transition: .doorsOpenVertical(withDuration: 0.3))
        } else if node.name == "highscore" {
            run(SKAction.playSoundFileNamed("buttonSound.wav"))
            setupPanel()
        } else if node.name == "setting" {
            run(SKAction.playSoundFileNamed("buttonSound.wav"))
            setupSetting()
        } else if node.name == "container" {
            currInfoPageNum = 1 //reset the page counter
            istanceInfoActive = false
            run(SKAction.playSoundFileNamed("buttonSound.wav"))
            containerNode.removeFromParent()
        } else if node.name == "theBoy" {
            run(SKAction.playSoundFileNamed("playerSelect.mp3"))
            let playerSelected = UserDefaults.standard.object(forKey: playerSelectedKey) as? String
            if playerSelected! != "TheBoy" { // if already selected is useless
                UserDefaults.standard.setValue("TheBoy", forKey: playerSelectedKey)
                updatePlayerSelection()
            }
        } else if node.name == "cuteGirl" {
            run(SKAction.playSoundFileNamed("playerSelect.mp3"))
            let playerSelected = UserDefaults.standard.object(forKey: playerSelectedKey) as? String
            if playerSelected! != "CuteGirl" { // if already selected is useless
                UserDefaults.standard.setValue("CuteGirl", forKey: playerSelectedKey)
                updatePlayerSelection()
            }
        } else if node.name == "music" {
            run(SKAction.playSoundFileNamed("buttonSound.wav"))
            let node = node as! SKSpriteNode
            SKTAudio.musicEnabled = !SKTAudio.musicEnabled
            node.texture = SKTexture(imageNamed: SKTAudio.musicEnabled ? "musicOn" : "musicOff")
            SKTAudio.sharedInstance().playBGMusic("backgroundMusic.mp3")
        } else if node.name == "effect" {
            let node = node as! SKSpriteNode
            effectEnabled = !effectEnabled
            node.texture = SKTexture(imageNamed: effectEnabled ? "effectOn" : "effectOff")
            run(SKAction.playSoundFileNamed("buttonSound.wav"))
        } else if node.name == "info" {
            if(istanceInfoActive == false){
                run(SKAction.playSoundFileNamed("buttonSound.wav"))
                setupInfo()
                istanceInfoActive = true
            }
        } else if node.name == "infoArrowRight"{
            if(currInfoPageNum <= pageInfoNum) {
                run(SKAction.playSoundFileNamed("buttonSound.wav"))
                currInfoPageNum += 1
                updateInfo()
            }
        } else if node.name == "infoArrowLeft"{
            if(currInfoPageNum >= 1) {
                run(SKAction.playSoundFileNamed("buttonSound.wav"))
                currInfoPageNum -= 1
                updateInfo()
            }
        }
    }
}

//MARK: - Configurations
extension MainMenu {
    func setupBG() {
        let bgNode = SKSpriteNode(imageNamed: "menu_background")
        bgNode.zPosition = -1.0
        bgNode.anchorPoint = .zero
        bgNode.size = self.size
        bgNode.position = .zero
        addChild(bgNode)
    }
    
    func setupNodes() {
        let play = SKSpriteNode(imageNamed: "play")
        play.name = "play"
        play.setScale(1.2 * buttonScale)
        play.zPosition = 10.0
        play.position = CGPoint(x: size.width/2.0, y: size.height/2.0)
        addChild(play)
        
        let highscore = SKSpriteNode(imageNamed: "highscore")
        highscore.name = "highscore"
        highscore.setScale(buttonScale)
        highscore.zPosition = 10.0
        highscore.position = CGPoint(x: size.width/2.0, y: size.height/2.0 + highscore.frame.height + 60.0)
        addChild(highscore)
        
        let setting = SKSpriteNode(imageNamed: "setting")
        setting.name = "setting"
        setting.setScale(buttonScale)
        setting.zPosition = 10.0
        setting.position = CGPoint(x: size.width/2.0, y: size.height/2.0 - setting.size.height - 50.0)
        addChild(setting)
        
        let info = SKSpriteNode(imageNamed: "info")
        info.setScale(0.625)
        info.zPosition = 50.0
        info.name = "info"
        info.position = CGPoint(x: info.frame.width/2 + 50, y: size.height/2 + play.frame.height + 120)
        addChild(info)
    }
    
    func setupPlayer() {
        // Setup the boy
        let theBoy = SKSpriteNode(imageNamed: "TheBoy/Run (1)")
        theBoy.name = "theBoy"
        theBoy.zPosition = 10.0
        theBoy.position = CGPoint(x: size.width/2.0 + size.width/4.0, y: size.height/2.0)
        addChild(theBoy)
        // Add animations
        var theBoyFrames = [SKTexture]()
        for i in 1...15 {
            let frameName = "TheBoy/Run (\(i))"
            theBoyFrames.append(SKTexture(imageNamed: frameName))
        }
        // Animation activated
        theBoy.run(SKAction.repeatForever(SKAction.animate(with: theBoyFrames, timePerFrame: timePerFrameTheBoyAnimations)), withKey: "theBoyAnimation")
        
        // Setup the girl
        let cuteGirl = SKSpriteNode(imageNamed: "CuteGirl/Run (1)")
        cuteGirl.name = "cuteGirl"
        cuteGirl.zPosition = 10.0
        cuteGirl.xScale = CGFloat(-1)
        cuteGirl.position = CGPoint(x: size.width/4.0, y: size.height/2.0)
        addChild(cuteGirl)
        // Add animations
        var cuteGirlFrames = [SKTexture]()
        for i in 1...20 {
            let frameName = "CuteGirl/Run (\(i))"
            cuteGirlFrames.append(SKTexture(imageNamed: frameName))
        }
        // Animation activated
        cuteGirl.run(SKAction.repeatForever(SKAction.animate(with: cuteGirlFrames, timePerFrame: timePerFrameCuteGirlAnimations)), withKey: "cuteGirlAnimation")
    }
    
    func updatePlayerSelection() {
        let playerSelected = UserDefaults.standard.object(forKey: playerSelectedKey) as? String
        let zoomIn = SKAction.scale(by: 1.3, duration: 1) // animation select
   
        switch playerSelected! {
        case "TheBoy":
            let spriteNotSelected = self.childNode(withName: "cuteGirl") as! SKSpriteNode
            let spriteSelected = self.childNode(withName: "theBoy") as! SKSpriteNode
            // Resume and stop animation
            spriteNotSelected.action(forKey: "cuteGirlAnimation")?.speed = 0
            spriteSelected.action(forKey: "theBoyAnimation")?.speed = 1
            // Create selection animation
            spriteSelected.run(zoomIn)
            if !firstOpen {
                spriteNotSelected.run(zoomIn.reversed())
            }
            // Add selection label
            selectionLbl.position = CGPoint(x: spriteSelected.position.x,
                                            y: size.height/2.0 - selectionLbl.frame.height - 300.0)
            
        case "CuteGirl":
            let spriteNotSelected = self.childNode(withName: "theBoy") as! SKSpriteNode
            let spriteSelected = self.childNode(withName: "cuteGirl") as! SKSpriteNode
            // Resume and stop animation
            spriteNotSelected.action(forKey: "theBoyAnimation")?.speed = 0
            spriteSelected.action(forKey: "cuteGirlAnimation")?.speed = 1
            // Create selection animation
            spriteSelected.run(zoomIn)
            if !firstOpen {
                spriteNotSelected.run(zoomIn.reversed())
            }
            // Add selection label
            selectionLbl.position = CGPoint(x: spriteSelected.position.x,
                                            y: size.height/2.0 - selectionLbl.frame.height - 300.0)
            
        default:
            return
        }
        
        firstOpen = false // not useful anymore
    }
    
    func setupSelectionLabel() {
        selectionLbl.text = "Player Selected"
        selectionLbl.horizontalAlignmentMode = .center
        selectionLbl.fontSize = 60.0
        selectionLbl.zPosition = 25.0
        addChild(selectionLbl)
    }
    
    func setupPanel() {
        // Create a Container
        setupContainer()
        
        // Create a panel inside the container
        let panel = SKSpriteNode(imageNamed: "panel")
        panel.setScale(1.5)
        panel.zPosition = 20.0
        panel.position = .zero
        containerNode.addChild(panel)
        
        // Highscore
        let x = -panel.frame.width/2.0 + 300.0
        let highscoreLbl = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        highscoreLbl.text = "Highscore: \(ScoreGenerator.sharedInstance.getHighscore())"
        highscoreLbl.horizontalAlignmentMode = .left
        highscoreLbl.fontSize = 80.0
        highscoreLbl.zPosition = 25.0
        highscoreLbl.position = CGPoint(x: x, y: highscoreLbl.frame.height/2.0 - 30.0)
        panel.addChild(highscoreLbl)
        
        let scoreLbl = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        scoreLbl.text = "Last Score: \(ScoreGenerator.sharedInstance.getScore())"
        scoreLbl.horizontalAlignmentMode = .left
        scoreLbl.fontSize = 80.0
        scoreLbl.zPosition = 25.0
        scoreLbl.position = CGPoint(x: x, y: -scoreLbl.frame.height - 30.0)
        panel.addChild(scoreLbl)
    }
    
    func setupContainer() {
        containerNode = SKSpriteNode()
        containerNode.name = "container"
        containerNode.zPosition = 15.0
        containerNode.color = .clear // UIColor (white: 0.5, alpha 0.5)
        containerNode.size = size
        containerNode.position = CGPoint(x: size.width/2.0, y: size.height/2.0)
        addChild(containerNode)
    }
    
    func setupSetting() {
        // Create a Container
        setupContainer()
        
        // Create a panel inside the container
        let panel = SKSpriteNode(imageNamed: "panel")
        panel.setScale(1.5)
        panel.zPosition = 20.0
        panel.position = .zero
        containerNode.addChild(panel)
        
        // Music
        let music = SKSpriteNode(imageNamed: SKTAudio.musicEnabled ? "musicOn" : "musicOff")
        music.name = "music"
        music.setScale(0.875)
        music.zPosition = 25.0
        music.position = CGPoint(x: -music.frame.width - 50.0, y: 0.0)
        panel.addChild(music)
        
        // Sound
        let effect = SKSpriteNode(imageNamed: effectEnabled ? "effectOn" : "effectOff")
        effect.name = "effect"
        effect.setScale(0.875)
        effect.zPosition = 25.0
        effect.position = CGPoint(x: music.frame.width + 50.0, y: 0.0)
        panel.addChild(effect)
    }
    
    func setupInfo() {
        // Create a Container
        setupContainer()
        
        // Create a panel inside the container
        let panel = SKSpriteNode(imageNamed: "bigPanel")
        panel.name = "bigInfoPanel"
        panel.setScale(1)
        panel.zPosition = 20.0
        panel.position = .zero
        containerNode.addChild(panel)
        
        // add a right arrow to the panel
        let rightArrow = SKSpriteNode(imageNamed: "rightArrow")
        rightArrow.name = "infoArrowRight"
        rightArrow.setScale(0.5)
        rightArrow.zPosition = 20.0
        rightArrow.position = CGPoint(x: panel.position.x + panel.size.width/2 - 60, y: panel.position.y/2)
        
        panel.addChild(rightArrow)
        
        // add left arrow
        let leftArrow = SKSpriteNode(imageNamed: "leftArrow")
        leftArrow.name = "infoArrowLeft"
        leftArrow.setScale(0) // invisible arrow (no dimension)
        leftArrow.zPosition = 20.0
        leftArrow.position = CGPoint(x: -(panel.position.x + panel.size.width/2 - 60), y: panel.position.y/2)
        panel.addChild(leftArrow)
        
        // add info images to panel
        let info1 = SKSpriteNode(imageNamed: "infoImg1")
        info1.name = "info1"
        info1.zPosition = 30.0
        info1.position = CGPoint(x:panel.position.x - panel.size.width/4 + 20,y:panel.position.y + panel.size.height/4 - 40)
        info1.setScale(0) //invisible
        let info2 = SKSpriteNode(imageNamed: "infoImg2")
        info2.name = "info2"
        info2.position = CGPoint(x:panel.position.x + panel.size.width/4 - 20,y:panel.position.y + panel.size.height/4 - 40)
        info2.zPosition = 30.0
        info2.setScale(0) //invisible
        panel.addChild(info1)
        panel.addChild(info2)
        
        // Add text
        let infoLbl = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        infoLbl.name = "textInfo"
        infoLbl.text = "On your path, you have to use your skills to collect diamonds and jump over different kinds of obstacles."
        infoLbl.fontColor = .black
        infoLbl.fontSize = 65.0
        infoLbl.zPosition = 25.0
        infoLbl.preferredMaxLayoutWidth = panel.frame.width - 200
        infoLbl.numberOfLines = 0
        infoLbl.verticalAlignmentMode = .center
        infoLbl.horizontalAlignmentMode = .center
        infoLbl.lineBreakMode = .byWordWrapping
        panel.addChild(infoLbl)
    }
    
    func updateInfo(){
        let panel = containerNode.childNode(withName: "bigInfoPanel")as! SKSpriteNode
        let infoLbl = panel.childNode(withName: "textInfo") as? SKLabelNode
        let info1 = panel.childNode(withName: "info1") as! SKSpriteNode
        let info2 = panel.childNode(withName: "info2") as! SKSpriteNode
        
        if currInfoPageNum == 1{
            panel.childNode(withName: "infoArrowLeft")?.setScale(0) //set the left arrow invisible
            infoLbl?.verticalAlignmentMode = .center
            infoLbl?.fontSize = 65.0
            infoLbl?.text = "On your path, you have to use your skills to collect diamonds and jump over different kinds of obstacles."
            info1.setScale(0)
            info2.setScale(0)
        } else if currInfoPageNum > 1 && currInfoPageNum < pageInfoNum {
            panel.childNode(withName: "infoArrowLeft")?.setScale(0.5) //set the left arrow visible
            panel.childNode(withName: "infoArrowRight")?.setScale(0.5) //set the right arrow visible
                if currInfoPageNum == 2{
                    infoLbl?.verticalAlignmentMode = .top
                    infoLbl?.fontSize = 50.0
                    infoLbl?.text = "The sharp ones will steal a life from you, while the smooth rocks and trees will cause you to lose a diamond.\n"
                    info1.setScale(0.5)
                    info2.setScale(0.5)
                }
        } else if currInfoPageNum == pageInfoNum {
            info1.setScale(0)
            info2.setScale(0)
            infoLbl?.verticalAlignmentMode = .center
            infoLbl?.fontSize = 65.0
            panel.childNode(withName: "infoArrowRight")?.setScale(0) //set the right arrow invisible
            infoLbl?.text = "Don't forget to check out our watch app for a better experience."
        }
    }
}
