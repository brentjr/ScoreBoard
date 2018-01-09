//
//  Player+CoreDataProperties.swift
//  ScoreBoard
//
//  Created by Brent Roberts on 1/4/18.
//  Copyright © 2018 Gouda Labs. All rights reserved.
//
//

import Foundation
import CoreData


extension Player {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Player> {
        return NSFetchRequest<Player>(entityName: "Player")
    }

    @NSManaged public var name: String?
    @NSManaged public var points: [Int]?
    @NSManaged public var game: Game?

}
