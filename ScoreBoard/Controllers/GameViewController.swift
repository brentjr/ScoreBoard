//
//  ActiveGameViewController.swift
//  ScoreBoard
//
//  Created by Brent Roberts on 1/2/18.
//  Copyright © 2018 Gouda Labs. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    var game: Game? {
        didSet {
            game = oldValue ?? game
        }
    }
    
    @IBOutlet private weak var winnerView: GameWinnerView!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var gameCompletionButton: UIBarButtonItem!
}

// MARK: - View lifecycle
extension GameViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if let game = game {
            title = game.title?.uppercased()
            setGameCompleteStatus(isComplete: game.isComplete, animated: false)
        }
        
        addNotificationObservers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
        winnerView.hide(animated: false)
    }
}

// MARK: - UICollectionViewDataSource
extension GameViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let playerCount = game?.players?.count ?? 0
        if playerCount == 0 {
            let messageLbl = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
            messageLbl.text = "Go to the game settings and add a player to get started."
            messageLbl.textAlignment = .center
            messageLbl.numberOfLines = 0
            messageLbl.sizeToFit()
            collectionView.backgroundView = messageLbl
        } else {
        
            collectionView.backgroundView = nil 
        }
        return playerCount
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let game = game else {
            return 0
        }
        var pointsCount = largestPoints()
        if !game.isComplete || pointsCount == 0 {
            pointsCount += 1
        }
        return pointsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.CellIds.gameHeader, for: indexPath) as! GameSectionHeader
        sectionHeader.player = getPlayerForSection(indexPath.section)
        return sectionHeader
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell

        guard let game = game else {
            return UICollectionViewCell()
        }
        
        let points = getPlayerForSection(indexPath.section)?.points ?? []
        
        if (game.isComplete && indexPath.item == points.count) || (indexPath.item > points.count) {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIds.gameItem, for: indexPath as IndexPath)
            (cell as! GameItemCell).label.text = ""
        } else if indexPath.item < points.count {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIds.gameItem, for: indexPath as IndexPath)
            (cell as! GameItemCell).label.text = "\(points[indexPath.item])"
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIds.gameAddPoints, for: indexPath as IndexPath)
        }
        
        let border = CALayer()
        border.backgroundColor = UIColor(red: (211/255.0), green: (211/255.0), blue: (211/255.0), alpha: 0.5).cgColor
        border.frame = CGRect(x: 0, y: cell.frame.size.height - 1, width: cell.frame.size.width, height: 0.5)
        cell.layer.addSublayer(border)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension GameViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return
        }
        
        let vc = UIStoryboard(name: Constants.StoryboardNames.main, bundle: nil).instantiateViewController(withIdentifier: Constants.StoryboardIds.modifyPoints) as! ModifyPointsViewController
        if let points = getPlayerForSection(indexPath.section)?.points, indexPath.row < points.count {
            vc.originalValue = points[indexPath.row]

        }
        vc.delegate = self
        
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: 250, height: 350)
        
        let popover = vc.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = cell
        popover.sourceRect = cell.bounds
//        popover.permittedArrowDirections = [.left, .right]
        present(vc, animated: true, completion: nil)
    }
}

// MARK: - Modify points popover delegate
extension GameViewController: UIPopoverPresentationControllerDelegate, ModifyPointsViewControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func pointsDeleted() {
        guard let game = game, let indexPath = collectionView.indexPathsForSelectedItems?[0], let player = getPlayerForSection(indexPath.section) else {
            return
        }
        if var points = player.points, indexPath.item < points.count {
            points.remove(at: indexPath.item)
            player.points = points
            GameService.shared.saveGame(game)
            collectionView.reloadData()
        }
    }
    
    func pointsModified(value: Int) {
        guard let game = game, let indexPath = collectionView.indexPathsForSelectedItems?[0], let player = getPlayerForSection(indexPath.section) else {
            return
        }
        
        if var points = player.points, indexPath.item < points.count {
            points[indexPath.item] = value
            player.points = points
        } else if var points = player.points {
            points.append(value)
            player.points = points
        } else {
            player.points = [value]
        }
        
        GameService.shared.saveGame(game)
        collectionView.reloadData()
    }
}

// MARK: - IBActions
private extension GameViewController {
    
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
    
    @IBAction func gameCompletionBtnTapped(_ sender: Any) {
        guard let game = game else {
            return
        }
        
        game.isComplete = !game.isComplete
        GameService.shared.saveGame(game)
        setGameCompleteStatus(isComplete: game.isComplete, animated: true)
        let notificationDict: [String: Game] = [Constants.NotificationKeys.game: game]
        NotificationCenter.default.post(name: .gameEdited, object: self, userInfo: notificationDict)
    }
}

// MARK: - Notification handling
private extension GameViewController {
    
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(onGameEdited(_:)), name: .gameEdited, object: nil);
    }
    
    @objc private func onGameEdited(_ notification: NSNotification) {
        guard let game = notification.userInfo?[Constants.NotificationKeys.game] as? Game else {
            return
        }
        
        self.game = game
        title = game.title
        setGameCompleteStatus(isComplete: game.isComplete, animated: false)
        collectionView.reloadData()
    }
}

// MARK: - Other
private extension GameViewController {
    
    private func largestPoints() -> Int {
        guard let players = game?.players?.allObjects as? [Player] else {
            return 0
        }
        
        var hi = 0
        for player in players {
            if let count = player.points?.count, count > hi {
                hi = count
            }
        }
        return hi
    }
    
    private func getPlayerForSection(_ section: Int) -> Player? {
        return game?.sortedPlayers()[section]
    }
    
    private func setGameCompleteStatus(isComplete: Bool, animated: Bool) {        
        if isComplete {
            let winner = game?.winnersString() ?? "No one"
            winnerView.setWinner(name: winner, animated: animated)
            gameCompletionButton.title = "Resume Game"
            collectionView.allowsSelection = false
            collectionView.reloadData()
        } else {
            winnerView.hide(animated: animated)
            gameCompletionButton.title = "End Game"
            collectionView.allowsSelection = true
            collectionView.reloadData()
        }
    }
}
