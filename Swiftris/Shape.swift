//
//  Shape.swift
//  Swiftris
//
//  Created by Christina Saylor on 3/6/17.
//  Copyright © 2017 Christina Saylor. All rights reserved.
//

import SpriteKit

let NumOrientations: UInt32 = 4

enum Orientation: Int, CustomStringConvertible {
    case Zero = 0, Ninety, OneEighty, TwoSeventy
    
    //a shape can face one of four directions at any given point.
    var description: String {
        switch self {
        case .Zero:
            return "0"
        case .Ninety:
            return "90"
        case .OneEighty:
            return "180"
        case .TwoSeventy:
            return "270"
        }
    }
    
    static func random() -> Orientation {
        return
    Orientation(rawValue: Int(arc4random_uniform(NumOrientations)))!
    }
    
    //returns the next orientation when traveling either clockwise or counterclockwise
    static func rotate(orientation:Orientation, clockwise:
        Bool) -> Orientation {
        var rotated = orientation.rawValue + (clockwise ? 1 : -1)
        
        if rotated > Orientation.TwoSeventy.rawValue {
            rotated = Orientation.Zero.rawValue
        }
        else if rotated < 0 {
            rotated = Orientation.TwoSeventy.rawValue
        }
        
        return Orientation(rawValue: rotated)!
    }
}

//the number of total shape varieties
let NumShapeTypes: UInt32 = 7

//shape indexes
let FirstBlockIdx: Int = 0
let SecondBlockIdx: Int = 1
let ThirdBlockIdx: Int = 2
let FourthBlockIdx: Int = 3

class Shape: Hashable, CustomStringConvertible {
    
    //color of the shape
    let color:BlockColor
    
    //the blocks comprising the shape
    var blocks = Array<Block>()
    
    //the current orientation of the shape
    var orientation: Orientation
    
    //the column and row representing the shape's anchor point
    var column, row:Int
    
    //required overrides
    //subclasses must override this property
    //defines a computed dictionary using square braces; used to map one object to another. The first object type listed defines the "key" and the second defines a "value". Keys map one-to-one with values and duplicate keys may not exist.
    var blockRowColumnPositions:
        [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [:]
    }
    
    //subclasses must override this property
    var bottomBlocksForOrientations:[Orientation: Array<Block>] {
        return [:]
    }
    
    //returns the bottom blocks of the shape at its current orientation
    var bottomBlocks:Array<Block> {
        guard let bottomBlocks =
bottomBlocksForOrientations[orientation]
else {
        return []
    }
    return bottomBlocks
    }
    
    var hashValue:Int {
        //iterates through entire "blocks" array. Exclusive-or each block's hashValue together and create a single hashValue for the shape they comprise
        return blocks.reduce(0) {
            $0.hashValue ^ $1.hashValue }
        }
    
    var description: String {
        return "\(color) block facing \(orientation): \(blocks[FirstBlockIdx]), \(blocks[SecondBlockIdx]), \(blocks[ThirdBlockIdx]), \(blocks[FourthBlockIdx])"
    }
    
    init(column:Int, row:Int, color:BlockColor, orientation:Orientation) {
        self.color = color
        self.column = column
        self.row = row
        self.orientation = orientation
        
        initializeBlocks()
    }
    
    convenience init(column:Int, row:Int)
    {
        self.init(column:column, row:row, color:BlockColor.random(),
                  orientation:Orientation.random())
    }
    
    //define a final function (cannot be overriden by subclasses)
    final func initializeBlocks() {
        guard let blockRowColumnTranslations = blockRowColumnPositions[orientation] else {
            return
        }
        //the map function adds each "Block" returned by the code to the "blocks" array
        blocks = blockRowColumnTranslations.map { (diff) -> Block in
            
            return Block(column: column + diff.columnDiff, row: row + diff.rowDiff, color: color)
        }
    }
    
    final func rotateBlocks(orientation: Orientation) {
        guard let blockRowColumnTranslation:Array<(columnDiff: Int, rowDiff: Int)> = blockRowColumnPositions[orientation] else {
                return
            }
        //loop through the blocks and assign them their row and column based on the translations provided by the shape's subclass
        for (idx, diff) in blockRowColumnTranslation.enumerate() {
                blocks[idx].column = column + diff.columnDiff
                blocks[idx].row = row + diff.rowDiff
        }
    }
    
    final func rotateClockwise() {
        let newOrientation = Orientation.rotate(orientation, clockwise: true)
        rotateBlocks(newOrientation)
        orientation = newOrientation
    }
    
    final func rotateCounterClockwise() {
        let newOrientation = Orientation.rotate(orientation, clockwise: false)
        
        rotateBlocks(newOrientation)
        orientation = newOrientation
    }
    
    final func lowerShapeByOneRow() {
        shiftBy(0, rows:1)
    }
    
    final func raiseShapeByOneRow() {
        shiftBy(0, rows: -1)
    }
    
    final func shiftRightByOneColumn() {
        shiftBy(1, rows: 0)
    }
    
    final func shiftLeftByOneColumn() {
        shiftBy(-1, rows: 0)
    }
    
    //adjusts each row and column
    final func shiftBy(columns: Int, rows: Int) {
        self.column += columns
        self.row += rows
        for block in blocks {
            block.column += columns
            block.row += rows
        }
    }
    
    //set the "column" and "row" properties before rotating the lbocks to their current orientation which causes an accurate realignment of all blocks relative to the new "row" and "column" properties
    final func moveTo(column: Int, row: Int)
    {
        self.column = column
        self.row = row
        rotateBlocks(orientation)
    }
    
    final class func random(startingColumn:Int, startingRow:Int) -> Shape {
        
        //Generates a random shape
        switch Int(arc4random_uniform(NumShapeTypes)) {
        case 0:
            return SquareShape(column:startingColumn, row:startingRow)
        case 1:
            return LineShape(column:startingColumn, row:startingRow)
        case 2:
            return TShape(column:startingColumn, row:startingRow)
        case 3:
            return LShape(column:startingColumn, row:startingRow)
        case 4:
            return JShape(column: startingColumn, row:startingRow)
        case 5:
            return SShape(column:startingColumn, row:startingRow)
        default:
            return ZShape(column:startingColumn, row:startingRow)
            
        }
    }
}

    func ==(lhs: Shape, rhs: Shape) -> Bool {
    return lhs.row == rhs.row && lhs.column == rhs.column
    }
    
    




