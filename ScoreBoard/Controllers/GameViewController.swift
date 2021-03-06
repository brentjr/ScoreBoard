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
        guard let game = game else {
            return 0
        }
        var pointsCount = largestPoints() + 1
        if !game.isComplete || pointsCount == 0 {
            pointsCount += 1
        }
        return pointsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.CellIds.gameSectionHeader, for: indexPath) as! GameSectionHeader
        if indexPath.section == 0 {
            sectionHeader.label.text = "Score Total"
        } else {
            sectionHeader.label.text = "\(indexPath.section)"
        }
        return sectionHeader
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell

        guard let game = game else {
            return UICollectionViewCell()
        }

        let player = getPlayerForSection(indexPath.item)
        let points = player?.points ?? []
        let lastPointIndex = points.count + 1

        if indexPath.section == 0 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIds.gameTotalScore, for: indexPath)
            (cell as! GameTotalScoreCell).player = player
        } else if (game.isComplete && indexPath.section == lastPointIndex) || (indexPath.section > lastPointIndex) {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIds.gameItem, for: indexPath)
            (cell as! GameItemCell).label.text = ""
        } else if indexPath.section < lastPointIndex {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIds.gameItem, for: indexPath)
            (cell as! GameItemCell).label.text = "\(points[indexPath.section - 1])"
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIds.gameAddPoints, for: indexPath)
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
        if indexPath.section == 0 {
            return
        }
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return
        }
        
        let vc = UIStoryboard(name: Constants.StoryboardNames.main, bundle: nil).instantiateViewController(withIdentifier: Constants.StoryboardIds.modifyPoints) as! ModifyPointsViewController
        if let points = getPlayerForSection(indexPath.item)?.points, indexPath.section <= points.count {
            vc.originalValue = points[indexPath.section - 1]
        }
        vc.delegate = self
        
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: 250, height: 350)
        
        let popover = vc.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = cell
        popover.sourceRect = cell.bounds
        present(vc, animated: true, completion: nil)
    }
}

// MARK: - Modify points popover delegate
extension GameViewController: UIPopoverPresentationControllerDelegate, ModifyPointsViewControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func pointsDeleted() {
        guard let game = game, let indexPath = collectionView.indexPathsForSelectedItems?[0], let player = getPlayerForSection(indexPath.item) else {
            return
        }
        if var points = player.points, indexPath.section <= points.count {
            points.remove(at: indexPath.section - 1)
            player.points = points
            GameService.shared.saveGame(game)
            collectionView.reloadData()
        }
    }
    
    func pointsModified(value: Int) {
        guard let game = game, let indexPath = collectionView.indexPathsForSelectedItems?[0], let player = getPlayerForSection(indexPath.item) else {
            return
        }
        
        if var points = player.points, indexPath.section <= points.count {
            points[indexPath.section - 1] = value
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
        
        let vc = UIStoryboard(name: Constants.StoryboardNames.main, bundle: nil).instantiateViewController(withIdentifier: Constants.StoryboardIds.createGame) as! UINavigationController
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

    @IBAction func timerBtnTapped(_ sender: Any) {
        let vc = UIStoryboard(name: Constants.StoryboardNames.main, bundle: nil).instantiateViewController(withIdentifier: Constants.StoryboardIds.timer) as! TimerViewController
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: 250, height: 350)

        let popover = vc.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = self.view
        popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        popover.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        present(vc, animated: true, completion: nil)
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
