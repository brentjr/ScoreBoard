//
//  TestTableViewCell.swift
//  ScoreBoard
//
//  Created by Brent Roberts on 12/30/17.
//  Copyright © 2017 Gouda Labs. All rights reserved.
//

import UIKit

class GameListTableViewCell: UITableViewCell {
    
    var game: Game? {
        didSet {
            guard let game = game else {
                titleLabel.text = ""
                dateLabel.text = ""
                playersLabel.text = ""
                return
            }
            
            // Title
            titleLabel.text = game.title?.uppercased()
            
            // Date
            if let date = game.createdDate as Date? {
                let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
                let dateFormatter = DateFormatter()
                
                if calendar.isDateInToday(date) {
                    dateFormatter.dateStyle = .none
                    dateFormatter.timeStyle = .short
                } else {
                    dateFormatter.setLocalizedDateFormatFromTemplate("MM/dd/yy")
                }

                dateLabel.text = dateFormatter.string(from: date)
            } else {
                dateLabel.text = ""
            }
            
            // Status
            if game.isComplete {
                let winner = game.winnersString()
                playersLabel.textColor = UIColor(red: (218/255.0), green: (165/255.0), blue: (32/255.0), alpha: 1.0)
                playersLabel.text = "Winner: \(winner)"
            } else {
                playersLabel.textColor = UIColor.black
                playersLabel.text = "Game in progress"
            }
        }
    }

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var playersLabel: UILabel!
}
