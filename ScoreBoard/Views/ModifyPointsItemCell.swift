//
//  ModifyPointsItemCell.swift
//  ScoreBoard
//
//  Created by Brent Roberts on 1/8/18.
//  Copyright © 2018 Gouda Labs. All rights reserved.
//

import UIKit

class ModifyPointsItemCell: UICollectionViewCell {
    
    var value: String? {
        didSet {
            guard let value = value else {
                label.text = ""
                return
            }
            label.text = value
        }
    }
    
    @IBOutlet private weak var label: UILabel!
}
