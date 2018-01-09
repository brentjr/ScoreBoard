//
//  NotificationStuff.swift
//  ScoreBoard
//
//  Created by Brent Roberts on 12/31/17.
//  Copyright © 2017 Gouda Labs. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let gameCreated = Notification.Name("game_created")
    static let gameEdited = Notification.Name("game_edited")
    static let gameArchived = Notification.Name("game_archived")
    static let gameReactivated = Notification.Name("game_reactivated")
}
