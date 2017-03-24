//
//  GameViewController.swift
//  Swiftris
//
//  Created by Christina Saylor on 3/6/17.
//  Copyright (c) 2017 Christina Saylor. All rights reserved.
//

import UIKit
import SpriteKit

 class GameViewController: UIViewController, SwiftrisDelegate, UIGestureRecognizerDelegate {
    
    var scene: GameScene!
    var swiftris:Swiftris!
    
    //keeps track of the last point on the screen at which a shape movement occurred or where a pan begins
    var panPointReference:CGPoint?

    @IBOutlet weak var scoreLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configure the view
        let skView = view as! SKView
        
        skView.multipleTouchEnabled = false
        
        //Create and configure the scene
        
        scene = GameScene(size: skView.bounds.size)

        
        scene.scaleMode = .AspectFill
        
        
        scene.tick = didTick
        
        swiftris = Swiftris()
        swiftris.delegate = self
        
        
        //Present the scene
        skView.presentScene(scene)
        
    }
    @IBOutlet weak var levelLabel: UILabel!
    
    


    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
   
    
    @IBAction func didTap(sender: UITapGestureRecognizer) {
        swiftris.rotateShape()
    }

    
    
    @IBAction func didSwipe(sender: UISwipeGestureRecognizer) {
        
        swiftris.dropShape()
    }
   
    
    //Beginning of the restart button chain of events
    @IBAction func didRestart(sender: UIButton) {
        //explodes blocks currently in game
        swiftris.removeBlocks()
        
        //Tells swiftris to restart the game
        swiftris.restartGame()
    }
    
    @IBOutlet var UIMainMenu: UIView!
    
    @IBOutlet var UIstartButton: UIButton!
    
    
   //start button starts the game but can't start the game after it has been hidden once before
    @IBAction func startGame(sender: UIButton) {
        UIstartButton.hidden = true
        UIMainMenu.hidden = true
        swiftris.beginGame()
    }
    
    
    @IBAction func didPan(sender: UIPanGestureRecognizer) {
        
        //recover a point which defines the translation of the gesture relative to where it began
        let currentPoint = sender.translationInView(self.view)
        
        if let originalPoint = panPointReference {
            //check whether the x translation has crossed our threshold - 90% of BlockSize
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
                //if it has, check the velocity of the gesture. Velocity will give us direction (positive velocity represents movement to the right, negetive toward the left). We then move the shape in the corresponding direction and reset reference point
                
                if sender.velocityInView(self.view).x > CGFloat(0) {
                    swiftris.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    swiftris.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .Began {
            panPointReference = currentPoint
        }
    }
    
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
  
  //verifies is user if swiping or panning. If swipe doesn't pan - andrew
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
         if gestureRecognizer is UISwipeGestureRecognizer {
             if otherGestureRecognizer is UIPanGestureRecognizer {
                 return true
             }
         } else if gestureRecognizer is UIPanGestureRecognizer {
             if otherGestureRecognizer is UITapGestureRecognizer {
                 return true
             }
         }
         return false
     }
    
    
    
    func didTick() {
        swiftris.letShapeFall()
    }
    
    func nextShape() {
        let newShapes = swiftris.newShape()
        
        guard let fallingShape = newShapes.fallingShape else {
            return
        }
        
        self.scene.addPreviewShapeToScene(newShapes.nextShape!) {}
        
        self.scene.movePreviewShape(fallingShape) {
            
            //shuts down interaction with the view. Useful during states when we animate or shift blocks
            self.view.userInteractionEnabled = true
            self.scene.startTicking()
        }
    }
    
    func gameDidBegin(swiftris: Swiftris) {
        
        levelLabel.text = "\(swiftris.level)"
        scoreLabel.text = "\(swiftris.score)"
        scene.tickLengthMillis = TickLengthLevelOne
        
        if swiftris.nextShape != nil && swiftris.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(swiftris.nextShape!) {
                self.nextShape()
            }
        }else {
            nextShape()
        }
    }
    
    @IBOutlet var UIhighscore: UILabel!
    @IBOutlet var UIhighLevel: UILabel!
    
    
    func gameDidEnd(swiftris: Swiftris) {
        view.userInteractionEnabled = true
        scene.stopTicking()
        
        scene.playSound("Sounds/gameover.mp3")
        
        scene.animateCollapsingLines(swiftris.removeAllBlocks(), fallenBlocks: swiftris.removeAllBlocks()){}
        
        UIMainMenu.hidden = false
        UIstartButton.hidden = false
        
        //set label to highscore - AJ
        UIhighscore.text = String(userDefaults.integerForKey("highscore"))
        
        //set label to highest level - AJ
        UIhighLevel.text = String(userDefaults.integerForKey("highLevel"))
        
    }
    
    //Clears blocks and starts the game again when restart button is pressed - Justin
    func gameDidRestart(swiftris: Swiftris){
        scene.stopTicking()
        
        scene.playSound("Sounds/gameover.mp3")
        
        scene.animateCollapsingLines(swiftris.removeAllBlocks(), fallenBlocks: swiftris.removeAllBlocks()){
            swiftris.beginGame()
        }
    }
    
    func gameDidLevelUp(swiftris: Swiftris) {
        
        levelLabel.text = "\(swiftris.level)"
        
        if scene.tickLengthMillis >= 100 {
            scene.tickLengthMillis -= 100
        } else if scene.tickLengthMillis > 50 {
            scene.tickLengthMillis -= 50
        }
        
        scene.playSound("Sounds/levelup.mp3")
        
    }
    
    func gameShapeDidDrop(swiftris: Swiftris) {
        
        scene.stopTicking()
        
        scene.redrawShape(swiftris.fallingShape!) {
            swiftris.letShapeFall()
        }
        
        scene.playSound("Sounds/drop.mp3")
        
    }
    
    func gameShapeDidLand(swiftris: Swiftris) {
        scene.stopTicking()
        
        self.view.userInteractionEnabled = false
        
        let removedLines = swiftris.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.text = "\(swiftris.score)"
            
            scene.animateCollapsingLines(removedLines.linesRemoved, fallenBlocks:removedLines.fallenBlocks) {
                self.gameShapeDidLand(swiftris)
            }
            
            scene.playSound("Sounds/bomb.mp3")
        } else {
            nextShape()
        }
    }
    
    //After a shape has moved, redraw its representative sprites at their new locations
    func gameShapeDidMove(swiftris: Swiftris) {
        scene.redrawShape(swiftris.fallingShape!) {}
    }
}
