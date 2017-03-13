//
//  Swiftris.swift
//  Swiftris
//
//  Created by Christina Saylor on 3/7/17.
//  Copyright © 2017 Christina Saylor. All rights reserved.
//


//define total number of rows and columns on the game board
let NumColumns = 10
let NumRows = 20

//location of where each piece starts
let StartingColumn = 4
let StartingRow = 0

//location of the preview piece
let PreviewColumn = 12
let PreviewRow = 1

let PointsPerLine = 10
let LevelThreshold = 500

protocol SwiftrisDelegate {
    //invoked when the current round of swiftris ends
    func gameDidEnd(swiftris: Swiftris)
    
    //invoked after new game has begun
    func gameDidBegin(swiftris: Swiftris)
    
    //invoked when the falling shape has become part of the game board
    func gameShapeDidLand(swiftris:Swiftris)
    
    //invoked when the falling shape has changed location
    func gameShapeDidMove(swiftris:Swiftris)
    
    //invoked when falling shape has changed its locations after being dropped
    func gameShapeDidDrop(swiftris: Swiftris)
    
    //invoked when the game has reached a new level
    func gameDidLevelUp(swiftris:Swiftris)
}

class Swiftris {
    var blockArray:Array2D<Block>
    var nextShape:Shape?
    var fallingShape:Shape?
    var delegate:SwiftrisDelegate?
    var score = 0
    var level = 1
    
    init() {
        fallingShape = nil
        nextShape = nil
        blockArray = Array2D<Block> (columns: NumColumns, rows: NumRows)
    }
    
    func beginGame() {
        if (nextShape == nil) {
            nextShape = Shape.random(PreviewColumn, startingRow: PreviewRow)
        }
        delegate?.gameDidBegin(self)
    }
    
    //Assign nextShape (the preview shape) as the fallingShape (the moving block)
    //before moving fallingShape to the starting location, create a new preview shape
    func newShape() -> (fallingShape:Shape?, nextShape:Shape?) {
        fallingShape = nextShape
        nextShape = Shape.random(PreviewColumn, startingRow: PreviewRow)
        
        fallingShape?.moveTo(StartingColumn, row: StartingRow)
        
        //The game ends when a new shape located at the designated starting location collides with existing blocks. The player no longer as room to move the new shape
        guard detectIllegalPlacement() == false else {
            nextShape = fallingShape
            nextShape!.moveTo(PreviewColumn, row: PreviewRow)
            
            endGame()
            
            return (nil, nil)
        }
        
        return (fallingShape, nextShape)
    }
    
    //Checks both block boundary conditions
    //First, determines whether a block exceeds the legal size of the game board.
    //Second, determines whether a blokc's current location overlaps with an existing block
    func detectIllegalPlacement() -> Bool {
        guard let shape = fallingShape
            else {
                return false
        }
        for block in shape.blocks {
            if block.column < 0 || block.column >= NumColumns || block.row < 0 || block.row >= NumRows {
                return true
            } else if blockArray[block.column, block.row] != nil {
                return true
            }
        }
        return false
    }
    
    //adds the falling shape to the collection of blocks maintained by Swiftris
    //once the falling shape's blocks are part of the game board, we nullify fallingShape and notify the delegate of a new shape settling onto the game board
    func settleShape() {
        guard let shape = fallingShape
            else {
                return
        }
        
        for block in shape.blocks {
            blockArray[block.column, block.row] = block
        }
        fallingShape = nil
        delegate?.gameShapeDidLand(self)
    }
    
    //returns true when the shape's bottom blocks touches a block on the game board or reaches the bottom of the game board
    func detectTouch() -> Bool {
        guard let shape = fallingShape
            else {
                return false
        }
        for bottomBlock in shape.bottomBlocks {
            if bottomBlock.row == NumRows - 1 || blockArray[bottomBlock.column, bottomBlock.row + 1] != nil {
                return true
            }
        }
        return false
    }
    
    func endGame() {
        score = 0
        level = 1
        delegate?.gameDidEnd(self)
    }
    
    //returns two arrays: fallenBlocks and linesRemoved
    func removeCompletedLines() -> (linesRemoved: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>) {
        var removedLines = Array<Array<Block>>()
        for row in (1..<NumRows).reverse() {
            var rowOfBlocks = Array<Block>()
            
            //adds every block in a given row to a local array variable named rowOfBlocks. If it ends up with a full set (10 blocks in total) it counts that as a removed line and adds it to the return variable
            for column in 0..<NumColumns {
                guard let block = blockArray[column, row] else {
                    continue
                }
                rowOfBlocks.append(block)
            }
            if rowOfBlocks.count == NumColumns {
                removedLines.append(rowOfBlocks)
                
                for block in rowOfBlocks {
                    blockArray[block.column, block.row] = nil
                }
            }
        }
        
        //check to see if we recovered any lines at all. If not, return empty arrays
        if removedLines.count == 0 {
            return ([], [])
        }
        
        //add points to the player's score based on the number of lines they've created and their level. If their points exceed their level times 1000, they level up and we inform the delegate
        let pointsEarned = removedLines.count * PointsPerLine * level
        score += pointsEarned
        
        if score >= level * LevelThreshold {
            level += 1
            delegate?.gameDidLevelUp(self)
        }
        
        var fallenBlocks = Array<Array<Block>>()
        
        for column in 0..<NumColumns {
            var fallenBlocksArray = Array<Block>()
            
            //starting at the left-most column and above the bottom-most removed line, we count upwards towards the top of the game board. As we do so, we take each remaining block we find on the game board and lower it as far as possible. fallenBlocks is an array of arrays, we've filled each sub-array with blocks that fell to a new position as a result of the user clearing lines beneath them.
            for row in (1..<removedLines[0][0].row).reverse() {
                guard let block = blockArray[column, row] else {
                    continue
                }
                var newRow = row
                
                while (newRow < NumRows - 1 && blockArray[column, newRow + 1] == nil) {
                    newRow += 1
                }
                block.row = newRow
                blockArray[column, row] = nil
                blockArray[column, newRow] = block
                fallenBlocksArray.append(block)
        }
            if fallenBlocksArray.count > 0 {
                fallenBlocks.append(fallenBlocksArray)
            }
        }
        return (removedLines, fallenBlocks)
    }
    
    //loops through and creates rows of block in order for the game scene to animate them off the game board. Meanwhile, it nullifies each location in the block array to empty it entirely, preparing it for a new game
    func removeAllBlocks() -> Array<Array<Block>> {
        var allBlocks = Array<Array<Block>>()
        
        for row in 0..<NumRows {
            var rowOfBlocks = Array<Block>()
            
            for column in 0..<NumColumns {
                guard let block = blockArray[column, row] else {
                    continue
                }
                rowOfBlocks.append(block)
                blockArray[column, row] = nil
            }
            allBlocks.append(rowOfBlocks)
        }
        return allBlocks
    }
    
    //continues dropping the shape by a single row until it detects an illegal placement state
    func dropShape() {
        guard let shape = fallingShape
            else {
                return
        }
        
        while detectIllegalPlacement() == false {
            shape.lowerShapeByOneRow()
        }
        shape.raiseShapeByOneRow()
        delegate?.gameShapeDidDrop(self)
    }
    
    //called once every tick
    //attempts to lower the shape by one row and ends the game if it fails to do so without finding legal placement for it
    func letShapeFall() {
        guard let shape = fallingShape
            else {
                return
        }
        
        shape.lowerShapeByOneRow()
        if detectIllegalPlacement() {
            shape.raiseShapeByOneRow()
            if detectIllegalPlacement() {
                endGame()
            } else {
                settleShape()
            }
        } else {
            delegate?.gameShapeDidMove(self)
            
            if detectTouch() {
                settleShape()
            }
        }
    }
    
    //allows the player to rotate the shape clockwise as it falls
    //if the shape's new block positions violate the boundaries of the game or overalp with settled blocks, revert the rotation and return
    func rotateShape() {
        guard let shape = fallingShape
            else {
                return
        }
        shape.rotateClockwise()
        guard detectIllegalPlacement() == false else {
            shape.rotateCounterClockwise()
            return
        }
        delegate?.gameShapeDidMove(self)
    }
    
    func moveShapeLeft() {
        guard let shape = fallingShape else {
            return
        }
        
        shape.shiftLeftByOneColumn()
        
        guard detectIllegalPlacement() == false else {
            shape.shiftRightByOneColumn()
            return
        }
        delegate?.gameShapeDidMove(self)
    }
    
    func moveShapeRight() {
        guard let shape = fallingShape
            else {
                return
        }
        shape.shiftRightByOneColumn()
        guard detectIllegalPlacement() == false else {
            shape.shiftLeftByOneColumn()
            return
        }
        delegate?.gameShapeDidMove(self)
    }
    
}