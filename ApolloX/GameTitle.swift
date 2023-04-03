//
//  GameTitle.swift
//  ApolloX
//
//  Created by Mayooran Thavajogarasa on 2023-04-02.
//

import Foundation
import SpriteKit

class GameTitleScene: SKScene {
    let playLabel = SKLabelNode(fontNamed: "The Bold Font")
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.width/2 + self.size.width/3)
        background.zPosition = 0
        self.addChild(background)
        
        let gameStartLabel = SKLabelNode(fontNamed: "The Bold Font")
        gameStartLabel.text = "ApolloX"
        gameStartLabel.fontSize = 200
        gameStartLabel.fontColor = SKColor.white
        gameStartLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height*0.7)
        gameStartLabel.zPosition = 1
        self.addChild(gameStartLabel)
        
        let howToLabel = SKLabelNode(fontNamed: "The Bold Font")
        howToLabel.text = "How To Play:"
        howToLabel.fontSize = 60
        howToLabel.fontColor = SKColor.white
        howToLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height*0.65)
        howToLabel.zPosition = 1
        self.addChild(howToLabel)
        
        playLabel.text = "Play"
        playLabel.fontSize = 90
        playLabel.fontColor = SKColor.white
        playLabel.zPosition = 1
        playLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.2)
        self.addChild(playLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        for touch: AnyObject in touches {
            let pointOfTouch = touch.location(in: (self))
            if playLabel.contains(pointOfTouch) {
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let startTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: startTransition)
            }
        }
    }
}
        
        
        
