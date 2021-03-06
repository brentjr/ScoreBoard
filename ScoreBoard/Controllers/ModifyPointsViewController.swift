//
//  ModifyPointsViewController.swift
//  ScoreBoard
//
//  Created by Brent Roberts on 1/7/18.
//  Copyright © 2018 Gouda Labs. All rights reserved.
//

import UIKit

protocol ModifyPointsViewControllerDelegate {
    
    func pointsModified(value: Int)
    func pointsDeleted()
}

class ModifyPointsViewController: UIViewController {
    
    var delegate: ModifyPointsViewControllerDelegate!
    var originalValue: Int?
    
    private let clear = "C"
    private let zero = "0"
//    private let delete = "←"
    private let delete = "+/-"
    private let numberOfSections = 4
    private let numberOfRows = 3
    
    @IBOutlet private weak var pointsLabel: UILabel!
    @IBOutlet private weak var numbersCollectionView: UICollectionView!
}

// MARK: - View lifecycle
extension ModifyPointsViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numbersCollectionView.dataSource = self
        numbersCollectionView.delegate = self
        
        if let originalValue = originalValue {
            pointsLabel.text = "\(originalValue)"
        } else {
            pointsLabel.text = zero
        }
    }
}

// MARK: - IBActions
extension ModifyPointsViewController {
    
    @IBAction private func enterBtnTapped(_ sender: Any) {
        if let delegate = delegate, let points = pointsLabel.text {
            delegate.pointsModified(value: 0 + Int(points)!)
        }
        pointsLabel.text = zero
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func deleteBtnTapped(_ sender: Any) {
        if let delegate = delegate {
            delegate.pointsDeleted()
        }
        pointsLabel.text = zero
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource
extension ModifyPointsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIds.modifyPointsCollection, for: indexPath as IndexPath) as! ModifyPointsItemCell

        switch (indexPath.section, indexPath.row) {
        case (3, 0):
            cell.value = clear
        case (3, 1):
            cell.value = zero
        case (3, 2):
            cell.value = delete
        default:
            let p = numberOfSections(in: collectionView) + self.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
            let index = (0..<indexPath.section).map { _ in 3 }.reduce(0, +)
            cell.value = "\((p - index) + indexPath.row)"
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ModifyPointsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch (indexPath.section, indexPath.row) {
        case (3, 0):
            pointsLabel.text = zero
            
        case (3, 1):
            guard let text = pointsLabel.text, text.count < 10 else {
                return
            }
            if pointsLabel.text != zero {
                pointsLabel.text = pointsLabel.text! + zero
            }
            
        case (3, 2):
            if pointsLabel.text != zero {
                if pointsLabel.text!.first == "-" {
                    pointsLabel.text?.remove(at: pointsLabel.text!.startIndex)
                } else {
                    pointsLabel.text = "-" + pointsLabel.text!
                }
            }
//            if pointsLabel.text?.count == 1 {
//                pointsLabel.text = zero
//            } else if pointsLabel.text != zero {
//                pointsLabel.text = String(pointsLabel.text!.dropLast())
//            }
            
        default:
            let cell = collectionView.cellForItem(at: indexPath) as! ModifyPointsItemCell
            guard let value = cell.value, let text = pointsLabel.text, text.count < 10 else {
                return
            }
            if pointsLabel.text == zero {
                pointsLabel.text = cell.value
            } else {
                pointsLabel.text = pointsLabel.text! + value
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ModifyPointsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = collectionView.frame.size
        size.width /= CGFloat(self.collectionView(collectionView, numberOfItemsInSection: indexPath.section))
        size.height /= CGFloat(numberOfSections(in: collectionView))
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
