//
//  Game+CoreDataClass.swift
//  ScoreBoard
//
//  Created by Brent Roberts on 12/30/17.
//  Copyright © 2017 Gouda Labs. All rights reserved.
//
//

import Foundation
import CoreData

enum WinnerThing: Int16 {
    case HighScore = 0
    case LowScore = 1
}

@objc(Game)
public class Game: NSManagedObject {
    
    var winnerThingEnum: WinnerThing {
        get {
            return WinnerThing(rawValue: self.winnerThing) ?? .HighScore
        }
        set {
            self.winnerThing = newValue.rawValue
        }
    }
}
