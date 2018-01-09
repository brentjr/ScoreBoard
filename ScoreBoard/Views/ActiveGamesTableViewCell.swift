//
//  TestTableViewCell.swift
//  ScoreBoard
//
//  Created by Brent Roberts on 12/30/17.
//  Copyright © 2017 Gouda Labs. All rights reserved.
//

import UIKit

class ActiveGamesTableViewCell: UITableViewCell {
    
    var game: Game? {
        didSet {
            guard let game = game else {
                titleLabel.text = ""
                dateLabel.text = ""
                playersLabel.text = ""
                return
            }
            
            // Title
            titleLabel.text = game.title
            
            // Date
            // TODO: format date based on how old it is
            if let date = game.createdDate as Date? {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .none
                dateFormatter.timeStyle = .short
                //            dateFormatter.setLocalizedDateFormatFromTemplate("MM/dd/yy")
                dateLabel.text = dateFormatter.string(from: date)
            } else {
                dateLabel.text = ""
            }
            
            // Players
            var playerNames: [String] = []
            if let players = game.players {
                for player in players {
                    if let playerName = (player as! Player).name {
                        playerNames.append(playerName)
                    }
                }
            }
            playersLabel.text = playerNames.joined(separator: ", ")
        }
    }

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var playersLabel: UILabel!
}
