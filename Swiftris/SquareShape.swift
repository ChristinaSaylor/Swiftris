//
//  SquareShape.swift
//  Swiftris
//
//  Created by Christina Saylor on 3/7/17.
//  Copyright © 2017 Christina Saylor. All rights reserved.
//

class SquareShape:Shape {
  //since the square shape will be identical at all orientations, it does not rotate
    
    //Each index of the arrays represents one of the four blocks ordered from 0 to 3
    override var blockRowColumnPositions:[Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [
            Orientation.Zero: [(0,0), (1,0), (0,1), (1,1)],
            Orientation.OneEighty: [(0,0), (1,0), (0,1), (1,1)],
            Orientation.Ninety: [(0,0), (1,0), (0,1), (1,1)],
            Orientation.TwoSeventy: [(0,0), (1,0), (0,1), (1,1)]
                ]
    }
    
    //Since the square shape does not rotate, it's bottom-most blocks are always the third and fourth blocks
    override var
bottomBlocksForOrientations: [Orientation : Array<Block>] {
        return [
            Orientation.Zero: [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.OneEighty: [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.Ninety: [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.TwoSeventy: [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]]
        ]
    }
}