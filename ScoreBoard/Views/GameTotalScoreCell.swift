//
//  ActiveGameSectionHeader.swift
//  ScoreBoard
//
//  Created by Brent Roberts on 1/4/18.
//  Copyright © 2018 Gouda Labs. All rights reserved.
//

import UIKit

class GameTotalScoreCell: UICollectionViewCell {
    
    var player: Player? {
        didSet {
            guard let player = player else {
                playerNameLabel.text = ""
                totalScoreHeader.text = "0"
                return
            }
            
            playerNameLabel.text = player.name
            totalScoreHeader.text = "\(player.totalScore())"
        }
    }
    
    @IBOutlet private weak var playerNameLabel: UILabel!
    @IBOutlet private weak var totalScoreHeader: UILabel!
}

//MARK: - View lifecycle
extension GameTotalScoreCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let sideLine = CALayer()
        sideLine.frame = CGRect(x: frame.width - 1, y: 0, width: 1, height: frame.height)
        sideLine.backgroundColor = UIColor.black.cgColor
        layer.addSublayer(sideLine)
    }
}
