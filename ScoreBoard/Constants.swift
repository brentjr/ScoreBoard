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
        static let gameListTable = "activeGamesTableViewCellID"
        static let gameSectionHeader = "gameSectionHeaderID"
        static let gameTotalScore = "gameTotalScoreCellID"
        static let gameItem = "activeGameItemCellID"
        static let gameAddPoints = "activeGameAddPointsCell"
        static let createGamePlayersTable = "playerTableViewCellID"
        static let modifyPointsCollection = "modifyPointsCollectionCellID"
    }
    
    struct SegueIds {
        static let game = "activeGameSegue"
    }
    
    struct StoryboardNames {
        static let main = "Main"
    }
    
    struct StoryboardIds {
        static let createGame = "createGameModal"
        static let modifyPoints = "modifyPointsViewController"
        static let timer = "timerViewController"
    }
}
