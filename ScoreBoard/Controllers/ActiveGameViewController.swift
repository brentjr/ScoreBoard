//
//  ActiveGameViewController.swift
//  ScoreBoard
//
//  Created by Brent Roberts on 1/2/18.
//  Copyright © 2018 Gouda Labs. All rights reserved.
//

import UIKit

class ActiveGameViewController: UIViewController {
    
    var game: Game? {
        didSet {
            game = oldValue ?? game
        }
    }
    
    @IBOutlet private weak var collectionView: UICollectionView!
}

// MARK: - View lifecycle
extension ActiveGameViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        if let layout = collectionView?.collectionViewLayout as? ActiveGameLayout {
            layout.delegate = self
        }
        
        if let game = game {
            title = game.title
        }
        
        addNotificationObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let tabBarController = tabBarController as? HomeTabBarController {
            tabBarController.hide()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let tabBarController = tabBarController as? HomeTabBarController {
            tabBarController.show()
        }
    }
}

// MARK: - IBActions
extension ActiveGameViewController {
    
    @IBAction private func settingsBtnTapped(_ sender: Any) {
        guard let game = game else {
            return
        }
        
        let vc = UIStoryboard(name: Constants.StoryboardNames.main, bundle: nil).instantiateViewController(withIdentifier: Constants.SegueIds.createGame) as! UINavigationController
        (vc.viewControllers[0] as! CreateGameViewController).game = game
        vc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        present(vc, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource
extension ActiveGameViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let players = game?.players else {
            return 0
        }
        return players.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let points = (game?.players?.allObjects[section] as? Player)?.points else {
            return 1
        }
        return points.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.CellIds.activeGameHeader, for: indexPath) as! ActiveGameSectionHeader
        sectionHeader.player = (game?.players?.allObjects[indexPath.section] as? Player)
        return sectionHeader
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let points = (game?.players?.allObjects[indexPath.section] as? Player)?.points, indexPath.item < points.count else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIds.activeGameAddPoints, for: indexPath as IndexPath) as! ActiveGameAddPointsCell
            cell.delegate = self
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIds.activeGameItem, for: indexPath as IndexPath) as! ActiveGameItemCell
        cell.label.text = "\(points[indexPath.item])"
        return cell
    }
}

// MARK: - ActiveGameLayoutDelegate
extension ActiveGameViewController: ActiveGameLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, headerInsetForItemAt indexPath: IndexPath) -> CGFloat {
        guard let navigationController = navigationController, let window = view.window else {
            return 0
        }
        return navigationController.navigationBar.frame.size.height + window.convert(UIApplication.shared.statusBarFrame, to: view).size.height
    }
}

// MARK: - ActiveGameAddPointsCellDelegate
extension ActiveGameViewController: ActiveGameAddPointsCellDelegate {
    
    func addPointsBtnTapped(cell: ActiveGameAddPointsCell) {
        guard let players = game?.players, let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        let vc = UIStoryboard(name: Constants.StoryboardNames.main, bundle: nil).instantiateViewController(withIdentifier: Constants.StoryboardIds.modifyPoints) as! ModifyPointsViewController
        vc.delegate = self
        vc.player = players.allObjects[indexPath.section] as! Player
        
        vc.modalPresentationStyle = .popover
        let popover = vc.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = cell
        popover.sourceRect = cell.bounds
        popover.permittedArrowDirections = [.left, .right]
        present(vc, animated: true, completion: nil)
    }
}

// MARK: - Modify points popover delegate
extension ActiveGameViewController: UIPopoverPresentationControllerDelegate, ModifyPointsViewControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func pointsModified(operation: ModifyPointsOperation, value: Int, player: Player) {
        guard let game = game else {
            return
        }
        
        var amount = 0
        switch operation {
        case .add:
            amount += value
        case .subtract:
            amount -= value
        }
        
        if var points = player.points {
            points.append(amount)
            player.points = points
        } else {
            player.points = [amount]
        }
        
        GameService.shared.saveGame(game)
        collectionView.reloadData()
    }
}

// MARK: - Notification handling
private extension ActiveGameViewController {
    
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(onGameEdited(_:)), name: .gameEdited, object: nil);
    }
    
    @objc private func onGameEdited(_ notification: NSNotification) {
        guard let game = notification.userInfo?[Constants.NotificationKeys.game] as? Game else {
            return
        }
        
        self.game = game
        title = game.title
        collectionView.reloadData()
    }
}
