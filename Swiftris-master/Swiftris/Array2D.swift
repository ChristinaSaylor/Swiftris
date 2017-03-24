//
//  Array2D.swift
//  Swiftris
//
//  Created by Christina Saylor on 3/6/17.
//  Copyright © 2017 Christina Saylor. All rights reserved.
//

//new class, using a typed parameter (<T>) which allows it to store any data type
class Array2D<T> {
    let columns: Int
    let rows: Int
    
    //declare an array; ? symbolizes an optional value
    var array: Array<T?>
    
    
    init(columns: Int, rows: Int) {
        
        self.columns = columns
        
        self.rows = rows
        
        //initialize array
        array = Array<T?>(count:rows * columns, repeatedValue: nil)
    }
    
    subscript(column: Int, row: Int) ->T? {
        get {
            return array[(row * columns) + column]
        }
        set(newValue) {
            array[(row * columns) + column] = newValue
        }
    }
}