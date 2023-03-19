//
//  GameScene.swift
//  ApolloX
//
//  Created by Mayooran Thavajogarasa on 2022-08-22.
//

import SpriteKit
import GameplayKit


var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    var powerlives = 3
    var livesNumber = 3
    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    var levelNumber = 0
    
    let powerLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    
    let player = SKSpriteNode(imageNamed: "playerShip")
    //let bulletSound = SKAction.playSoundFileNamed("laserSound", waitForCompletion: false)
    //let explosionSound = SKAction.playSoundFileNamed("explosionShort", waitForCompletion: false)
   
    
    
    //var backGroundPlayer = AVAudioPlayer()
    
    enum gameState {
        case preGame // game state is intro screen
        case inGame // game state is in game
        case afterGame // game state is outro
    }
    var currentGameState = gameState.inGame
    /*
    
    func playBackgroundMusic(fileName: String) {
        let url = Bundle.main.url(forResource: fileName, withExtension: nil)
        guard let newUrl = url else
        {
            print("Could not find file called \(fileName)")
            return
        }
        do {
            backGroundPlayer = try AVAudioPlayer(contentsOf: newUrl)
            backGroundPlayer.numberOfLoops = -1
            backGroundPlayer.prepareToPlay()
            backGroundPlayer.play()
        }
        catch let error as NSError {
            print(error.description)
        }
    }
     */
    struct PhysicsCategories {
        static let None : UInt32 = 0
        static let Player : UInt32 = 0b1 //1
        static let Bullet : UInt32 = 0b10 //2
        static let Enemy : UInt32 = 0b100 //4
        static let PowerUp : UInt32 = 0b110 //6
    }
    
    struct Bullet {
        // Define the bullet properties
        var name = "name"
        var src = "src"
        var delay:Double = 0.7
    }
    
    var standardBullet = Bullet(name: "playerBullet", src: "bullet", delay: 0.6)
    
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFF5)
    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }

    var gameArea: CGRect
    
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        
        gameScore = 0
        //playBackgroundMusic(fileName: "gameBGM.wav")
        self.physicsWorld.contactDelegate = self
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.width/2 + self.size.width/3)
        background.zPosition = 0
        self.addChild(background)
        
        powerLabel.text = "PowerUp"
        powerLabel.fontSize = 0
        powerLabel.fontColor = SKColor.yellow
        powerLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        powerLabel.position = CGPoint(x: self.size.width, y: self.size.height)
        powerLabel.zPosition = 100
        self.addChild(powerLabel)
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width*0.15, y: self.size.height*0.9)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        
        
        livesLabel.text = "Lives: 3"
        livesLabel.fontSize = 70
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width*0.85, y: self.size.height*0.9)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
       
        player.setScale(1)
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(player)
        
        setSpawn(levelDuration: startNewLevel())
        powerUpNow()

    }
    
    
    
    func powerUpNow() {
        powerLabel.text = "Speed: \(standardBullet.delay)"
        powerLabel.fontSize = 50
        powerLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        powerLabel.position = CGPoint(x: self.size.width*0.6, y: self.size.height*0.88)
        powerLabel.zPosition = 100
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp,scaleDown])
        powerLabel.run(scaleSequence)
        
    }
    
    func lostALife() {
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp,scaleDown])
        livesLabel.run(scaleSequence)
        
        if livesNumber == 0 {
            runGameOver()
        }

    }
    
    func addScore() {
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        if gameScore == 10 || gameScore == 25 || gameScore == 50 {
            
            setSpawn(levelDuration: startNewLevel())
        }
    }
    
    func runGameOver() {
        currentGameState = gameState.afterGame
        self.removeAllActions()
        self.enumerateChildNodes(withName: "Bullet") {
            bullet, stop in
            bullet.removeAllActions()
        }
        self.enumerateChildNodes(withName: "Enemy") {
            enemy, stop in
            enemy.removeAllActions()
        }
        
        self.enumerateChildNodes(withName: "PowerUp") {
            powerUp, stop in
            powerUp.removeAllActions()
        }
        
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
        
        
    }

    func changeScene() {
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let endtransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: endtransition)
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {

        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        var destroyPower = 3
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy {
            // If player has hit the enemy
            
            if body1.node != nil {
            spawnExplosion(spawnPosition: body1.node!.position)
            }

            //if body2.node != nil {
            //spawnExplosion(spawnPosition: body2.node!.position)
            //}
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            runGameOver()
        }
        
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy && (body2.node?.position.y)! < self.size.height {
            // If the bullet has hit the enemy
            if body1.node != nil {
            spawnExplosion(spawnPosition: body1.node!.position)
            }
            else {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            addScore()
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
        
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.PowerUp && (body2.node?.position.y)! < self.size.height {
            
            // If the bullet has hit the powerUp
            powerUpNow()
            powerlives -= 1
            if (powerlives == 0) {
                if body1.node != nil {
                    spawnExplosion(spawnPosition: body1.node!.position)
                }
                standardBullet.src = "powerbullet"
                standardBullet.delay = 0.2
                setSpawn(levelDuration: startNewLevel())
                powerUpNow()
                body1.node?.removeFromParent()
                body2.node?.removeFromParent()
                powerlives = 3
            }
        }
    }
    
    func spawnExplosion(spawnPosition: CGPoint) {
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([scaleIn, fadeOut, delete])
        explosion.run(explosionSequence)
    }
    func startNewLevel() -> Double {
        levelNumber += 1
        
        
        var levelDuration = TimeInterval()
        switch levelNumber{
        case 1: levelDuration = 2
        case 2: levelDuration = 1
        case 3: levelDuration = 0.8
        case 4: levelDuration = 0.5
            
        default:
            levelDuration = 0.5
            print("Cannot find level")
        }
        return levelDuration
    }
        
    func setSpawn(levelDuration: Double) {
        
        if self.action(forKey: "spawningEnemies") != nil{
            self.removeAction(forKey: "spawningEnemies")
        }
        
        if self.action(forKey: "spawningPowerUp") != nil{
            self.removeAction(forKey: "spawningPowerUp")
        }
        
        if self.action(forKey: "fireBullets") != nil{
            self.removeAction(forKey: "fireBullets")
        }
        
        let triggerBullet = SKAction.run(fireBullet)
        let spawn = SKAction.run(spawnEnemy)
        let spawnPower = SKAction.run(spawnPowerUp)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let waitToSpawnPower = SKAction.wait(forDuration: 5)
        let holdFire = SKAction.wait(forDuration: standardBullet.delay)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let fireSequence = SKAction.sequence([holdFire, triggerBullet])
        let powerSequence = SKAction.sequence([waitToSpawnPower, spawnPower])
        let spawnPowerForever = SKAction.repeatForever(powerSequence)
        let spawnForever = SKAction.repeatForever(spawnSequence)
        let fireForever = SKAction.repeatForever(fireSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
        self.run(spawnPowerForever, withKey: "spawningPowerUp")
        self.run(fireForever, withKey: "fireBullets")
        
    }
        
        
    
    
    func fireBullet() {
        let bullet = SKSpriteNode(imageNamed: standardBullet.src)
        bullet.name = "Bullet"
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        
        self.addChild(bullet)
        
        let bulletDelay = SKAction.wait(forDuration: 1)
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([moveBullet, deleteBullet, bulletDelay])
        bullet.run(bulletSequence)
        
        
    }
    
    func spawnPowerUp() {
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.1)
        
        let powerUp = SKSpriteNode (imageNamed: "star_power")
        powerUp.name = "Star"
        powerUp.setScale(0.15)
        powerUp.position = startPoint
        powerUp.zPosition = 3
        powerUp.physicsBody = SKPhysicsBody(rectangleOf: powerUp.size)
        powerUp.physicsBody!.affectedByGravity = false
        powerUp.physicsBody!.categoryBitMask = PhysicsCategories.PowerUp
        powerUp.physicsBody!.collisionBitMask = PhysicsCategories.None
        powerUp.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        
        self.addChild(powerUp)
        
        let movepowerUp = SKAction.move(to: endPoint, duration: 6)
        let deletepowerUp = SKAction.removeFromParent()
       
        let powerSequence = SKAction.sequence([movepowerUp, deletepowerUp, deletepowerUp])
        
        if currentGameState == gameState.inGame {
            powerUp.run(powerSequence)

        }
    }
    
    func spawnEnemy() {
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
    
        
        
        let enemy = SKSpriteNode (imageNamed: "enemyShip")
        enemy.name = "Enemy"
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 2)
        let deleteEnemy = SKAction.removeFromParent()
        let loseALifeAction = SKAction.run(lostALife)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseALifeAction])
        
        if currentGameState == gameState.inGame {
            enemy.run(enemySequence)
        }
        
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        
        let amountRotate = atan2(dy, dx)
        enemy.zRotation = amountRotate
    }
    
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            
            if currentGameState == gameState.inGame {
                player.position.x += amountDragged
            }
            // If player moves outside the boundaries
            
            if player.position.x > gameArea.maxX - player.size.width * 2 {
                player.position.x = gameArea.maxX - player.size.width * 2
            }
            
            if player.position.x < gameArea.minX + player.size.width * 2 {
                player.position.x = gameArea.minX + player.size.width * 2
            }
                
        }
    }
}
