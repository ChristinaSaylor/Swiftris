//
//  Block.swift
//  Swiftris
//
//  Created by Christina Saylor on 3/6/17.
//  Copyright © 2017 Christina Saylor. All rights reserved.
//

import SpriteKit

//number of colors allowed
let NumberOfColors: UInt32 = 6

enum BlockColor: Int, CustomStringConvertible {
    
    case Blue = 0, Orange, Purple, Red, Teal,Yellow
    
    var spriteName: String {
        switch self {
        case .Blue:
            return "blue"
        case.Orange:
            return "orange"
        case.Purple:
            return "purple"
        case.Red:
            return "red"
        case.Teal:
            return "teal"
        case.Yellow:
            return "yellow"
            
        }
    }
    
    var description: String{
        return self.spriteName
    }
    
    //returns a random choice among the colors found in BlockColor.
    static func random() ->BlockColor {
        return
    
    BlockColor(rawValue:Int(arc4random_uniform(NumberOfColors)))!
    }
    
}


    class Block: Hashable, CustomStringConvertible {
        
        //Once a color is assigned, it can no longer be reassigned. Blocks cannot change color mid-game
        let color: BlockColor
        
        //the column and row represent the location of the Block on the game board
        var column: Int
        var row: Int
        //SKSpriteNode represents the visual element of the Block which GameScene will use to render and animate each Block
        var sprite: SKSpriteNode?
        
        var spriteName: String {
            return color.spriteName
        }
        
        //returns the exclusive-or of the "row" and "column" properties to generate a unique integer for each Block
        var hashValue: Int {
            return self.column ^ self.row
        }
        
        var description: String {
            return "\(color): [\(column), \(row)]"
        }
        
        init(column:Int, row:Int, color:BlockColor) {
            self.column = column
            self.row = row
            self.color = color
        }
        
    }

    //compares one block with another. Returns true if both blocks are in the same location and of the same color
    func ==(lhs: Block, rhs: Block) -> Bool {
        return lhs.column == rhs.column && lhs.row == rhs.row && lhs.color.rawValue == rhs.color.rawValue
    }
