//
//  ActiveGameSectionHeader.swift
//  ScoreBoard
//
//  Created by Brent Roberts on 1/4/18.
//  Copyright © 2018 Gouda Labs. All rights reserved.
//

import UIKit

class GameSectionHeader: UICollectionReusableView {
    
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
extension GameSectionHeader {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        totalScoreHeader.layer.borderColor = UIColor.brown.cgColor
//        totalScoreHeader.layer.borderWidth = 1.0
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: frame.height - 1, width: frame.width, height: 1)
        bottomLine.backgroundColor = UIColor.black.cgColor
        layer.addSublayer(bottomLine)
    }
}
