//
//  ActiveGameAddPointsCell.swift
//  ScoreBoard
//
//  Created by Brent Roberts on 1/5/18.
//  Copyright © 2018 Gouda Labs. All rights reserved.
//

import UIKit

protocol ActiveGameAddPointsCellDelegate {
    
    func addPointsBtnTapped(cell: ActiveGameAddPointsCell)
}

class ActiveGameAddPointsCell: UICollectionViewCell {
    
    var delegate: ActiveGameAddPointsCellDelegate?
}

// MARK: - IBActions
extension ActiveGameAddPointsCell {
    
    @IBAction private func addPointsBtnTapped(_ sender: Any) {
        guard let delegate = delegate else {
            return
        }
        delegate.addPointsBtnTapped(cell: self)
    }
}
