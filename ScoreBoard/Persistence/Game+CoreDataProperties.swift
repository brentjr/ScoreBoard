//
//  Game+CoreDataProperties.swift
//  ScoreBoard
//
//  Created by Brent Roberts on 3/23/18.
//  Copyright © 2018 Gouda Labs. All rights reserved.
//
//

import Foundation
import CoreData


extension Game {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Game> {
        return NSFetchRequest<Game>(entityName: "Game")
    }

    @NSManaged public var createdDate: NSDate?
    @NSManaged public var isArchived: Bool
    @NSManaged public var isComplete: Bool
    @NSManaged public var playerDisplayOrder: Int16
    @NSManaged public var title: String?
    @NSManaged public var winCondition: Int16
    @NSManaged public var players: NSSet?

}

// MARK: Generated accessors for players
extension Game {

    @objc(addPlayersObject:)
    @NSManaged public func addToPlayers(_ value: Player)

    @objc(removePlayersObject:)
    @NSManaged public func removeFromPlayers(_ value: Player)

    @objc(addPlayers:)
    @NSManaged public func addToPlayers(_ values: NSSet)

    @objc(removePlayers:)
    @NSManaged public func removeFromPlayers(_ values: NSSet)

}
