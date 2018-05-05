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

enum WinCondition: Int16 {
    case HighScore = 0
    case LowScore = 1
}

enum PlayerDisplayOrder: Int16 {
    case alphabetical = 0
    case score = 1
}

@objc(Game)
public class Game: NSManagedObject {
    
    var winConditionEnum: WinCondition {
        get {
            return WinCondition(rawValue: self.winCondition) ?? .HighScore
        }
        set {
            self.winCondition = newValue.rawValue
        }
    }
    
    var playerDisplayOrderEnum: PlayerDisplayOrder {
        get {
            return PlayerDisplayOrder(rawValue: self.playerDisplayOrder) ?? .alphabetical
        }
        set {
            self.playerDisplayOrder = newValue.rawValue
        }
    }
    
    func sortedPlayers() -> [Player] {
        switch playerDisplayOrderEnum {
        case .alphabetical:
            return playersSortedByAlpha()
        case .score:
            return playersSortedByScore()
        }
    }
    
    func winners() -> [Player] {
        guard let players = players?.allObjects as? [Player], players.count > 0 else {
            return []
        }
        
        var winners = [Player]()
        var winScore: Int?
        
        switch winConditionEnum {
        case .HighScore:
            for player in players {
                if winScore == nil || player.totalScore() > winScore! {
                    winners.removeAll()
                    winners.append(player)
                    winScore = player.totalScore()
                } else if player.totalScore() == winScore! {
                    winners.append(player)
                }
            }
        case .LowScore:
            for player in players {
                if winScore == nil || player.totalScore() < winScore! {
                    winners.removeAll()
                    winners.append(player)
                    winScore = player.totalScore()
                } else if player.totalScore() == winScore! {
                    winners.append(player)
                }
            }
        }
        
        return winners
    }
    
    func winnersString() -> String {
        return (winners().map{$0.name!}).joined(separator: ", ")
    }
    
    private func playersSortedByAlpha() -> [Player] {
        guard let players = players else {
            return []
        }
        
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Player.name), ascending: true)
        return players.sortedArray(using: [sortDescriptor]) as! [Player]
    }
    
    private func playersSortedByScore() -> [Player] {
        guard let players = (players?.allObjects as? [Player]) else {
            return []
        }

        return players.sorted { p1, p2 -> Bool in
            guard let p1Points = p1.points else {
                return false
            }
            guard let p2Points = p2.points else {
                return true
            }
            
            let p1Total = p1Points.reduce(0, { x, y -> Int in
                x + y
            })
            let p2Total = p2Points.reduce(0, { x, y -> Int in
                x + y
            })
            
            // Sort alphabetical is score is the same
            if p1Total == p2Total  && p1.name != nil && p2.name != nil {
                return p1.name! < p2.name!
            }
            
            return p1Total > p2Total
        }
    }
}
