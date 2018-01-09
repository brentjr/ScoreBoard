//
//  EditPlayersTableViewCell.swift
//  ScoreBoard
//
//  Created by Brent Roberts on 1/2/18.
//  Copyright © 2018 Gouda Labs. All rights reserved.
//

import UIKit

protocol EditPlayersTableViewCellDelegate {
    
    func removePlayerBtnTapped(cell: EditPlayersTableViewCell)
}

class EditPlayersTableViewCell: UITableViewCell {
    
    var delegate: EditPlayersTableViewCellDelegate?
    var player: Player? {
        didSet {
            guard let player = player else {
                playerNameLabel.text = ""
                return
            }
            playerNameLabel.text = player.name
        }
    }
    
    @IBOutlet private weak var playerNameLabel: UILabel!
    @IBOutlet private weak var removePlayerButton: UIButton!
}

// MARK: - IBActions
extension EditPlayersTableViewCell {
    
    @IBAction private func removePlayerBtnTapped(_ sender: Any) {
        guard let delegate = delegate else {
            return
        }
        delegate.removePlayerBtnTapped(cell: self)
    }
}
