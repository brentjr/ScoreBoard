//
//  GameService.swift
//  ScoreBoard
//
//  Created by Brent Roberts on 12/31/17.
//  Copyright © 2017 Gouda Labs. All rights reserved.
//

import CoreData
import Foundation

final class GameService {
    
    static let shared = GameService()
    private lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "ScoreBoard")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private init() { }
    
    func allGames() -> [Game] {
        let fetchRequest = NSFetchRequest<Game>(entityName: "Game")
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch _ as NSError {
            // TODO: handle
            return []
        }
    }
    
    func activeGames() -> [Game] {
        let fetchRequest = NSFetchRequest<Game>(entityName: "Game")
        fetchRequest.predicate = NSPredicate(format: "isArchived == NO")
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch _ as NSError {
            // TODO: handle
            return []
        }
    }
    
    func archivedGames() -> [Game] {
        let fetchRequest = NSFetchRequest<Game>(entityName: "Game")
        fetchRequest.predicate = NSPredicate(format: "isArchived == YES")
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch _ as NSError {
            // TODO: handle
            return []
        }
    }
    
    func emptyGame() -> Game {
        let gameEntity = NSEntityDescription.entity(forEntityName: "Game", in: persistentContainer.viewContext)!
        return Game(entity: gameEntity, insertInto: nil)
    }
    
    func emptyPlayer() -> Player {
        let playerEntity = NSEntityDescription.entity(forEntityName: "Player", in: persistentContainer.viewContext)!
        return Player(entity: playerEntity, insertInto: nil)
    }
    
    func createPlayer(name: String, for game: Game) {
        let playerEntity = NSEntityDescription.entity(forEntityName: "Player", in: persistentContainer.viewContext)!
        let player = Player(entity: playerEntity, insertInto: persistentContainer.viewContext)
        player.name = name
        
        game.addToPlayers(player)
        save()
    }
    
    func insertGame(_ game: Game) -> Game {
        let gameEntity = NSEntityDescription.entity(forEntityName: "Game", in: persistentContainer.viewContext)!
        let gameInContext = Game(entity: gameEntity, insertInto: persistentContainer.viewContext)
        gameInContext.title = game.title
        gameInContext.createdDate = NSDate()
        gameInContext.isArchived = false
        
        if let players = game.players {
            for case let player as Player in players {
                let playerEntity = NSEntityDescription.entity(forEntityName: "Player", in: persistentContainer.viewContext)!
                let playerInContext = Player(entity: playerEntity, insertInto: persistentContainer.viewContext)
                playerInContext.name = player.name
                playerInContext.game = gameInContext
                playerInContext.points = []
                gameInContext.addToPlayers(playerInContext)
            }
        }
        
        save()
        return gameInContext
    }
    
    func deleteGame(_ game: Game) {
        persistentContainer.viewContext.delete(game)
        save()
    }
    
    func saveGame(_ game: Game) {
        save()
    }
    
    private func save() {
        do {
            try persistentContainer.viewContext.save()
        } catch _ as NSError {
            // TODO: handle
        }
    }
}
