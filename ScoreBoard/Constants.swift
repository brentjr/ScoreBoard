//
//  Constants.swift
//  ScoreBoard
//
//  Created by Brent Roberts on 1/8/18.
//  Copyright © 2018 Gouda Labs. All rights reserved.
//

import Foundation

struct Constants {
    
    struct NotificationKeys {
        static let game = "game"
    }
    
    struct CellIds {
        static let activeGamesTable = "activeGamesTableViewCellID"
        static let activeGameHeader = "activeGameSectionHeaderID"
        static let activeGameItem = "activeGameItemCellID"
        static let activeGameAddPoints = "activeGameAddPointsCell"
        static let createGamePlayersTable = "playerTableViewCellID"
        static let modifyPointsCollection = "modifyPointsCollectionCellID"
    }
    
    struct SegueIds {
        static let activeGame = "activeGameSegue"
        static let createGame = "createGameModal"
    }
    
    struct StoryboardNames {
        static let main = "Main"
    }
    
    struct StoryboardIds {
        static let modifyPoints = "modifyPointsViewController"
    }
}
