//
//  Player+CoreDataClass.swift
//  ScoreBoard
//
//  Created by Brent Roberts on 12/30/17.
//  Copyright © 2017 Gouda Labs. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Player)
public class Player: NSManagedObject {
    func totalScore() -> Int {
        guard let pointList = points else {
            return 0
        }
        var total = 0
        for pointItem in pointList {
            total += pointItem
        }
        return total
    }
}
