//
//  ItemOneViewController.swift
//  ScoreBoard
//
//  Created by Brent Roberts on 12/30/17.
//  Copyright © 2017 Gouda Labs. All rights reserved.
//

import UIKit

class GameListViewController: UIViewController {
    
    private let okButtonText = "OK"
    private let cancelButtonText = "Cancel"
    private let deleteButtonText = "Delete"
    private let deleteConfirmMessageText = "Game will be deleted permanently."
    
    private var games: [Game] = []
    @IBOutlet private weak var activeGamesTableView: UITableView!
}

// MARK: - View lifecycle
extension GameListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activeGamesTableView.dataSource = self
        activeGamesTableView.delegate = self
        
        games = GameService.shared.activeGames()
        activeGamesTableView.reloadData()
        
        addNotificationObservers()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == Constants.SegueIds.game {
            if let activeGameViewController = segue.destination as? GameViewController, let indexPath = activeGamesTableView.indexPathForSelectedRow {
                activeGameViewController.game = games[indexPath.row]
                activeGameViewController.hidesBottomBarWhenPushed = true
                activeGamesTableView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
}

// MARK: - IB Actions
extension GameListViewController {
    
    @IBAction func newGameBtnTapped(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createGameModal")
        vc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        present(vc, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension GameListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIds.gameListTable) as! GameListTableViewCell
        cell.game = games[indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate
extension GameListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: deleteButtonText) { (action, index) in
            self.tableView(tableView, deleteItemAt: indexPath)
        }
        
        return [delete]
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: deleteButtonText) { (action, sourceView, completionHandler) in
            self.tableView(tableView, deleteItemAt: indexPath)
        }
        
        let swipeAction = UISwipeActionsConfiguration(actions: [delete])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
    }
    
    private func tableView(_ tableView: UITableView, deleteItemAt indexPath: IndexPath) {
        let refreshAlert = UIAlertController(title: deleteButtonText, message: deleteConfirmMessageText, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: okButtonText, style: .default, handler: { (action: UIAlertAction!) in
            GameService.shared.deleteGame(self.games[indexPath.row])
            self.games.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: cancelButtonText, style: .cancel, handler: { (action: UIAlertAction!) in
            tableView.reloadData()
        }))
        tableView.isEditing = false
        present(refreshAlert, animated: true, completion: nil)
    }
    
    private func tableView(_ tableView: UITableView, archiveItemAt indexPath: IndexPath) {
        let game = self.games[indexPath.row]
        game.isArchived = true
        GameService.shared.saveGame(game)
        
        self.games.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.setEditing(false, animated: true)

        let notificationDict: [String: Game] = [Constants.NotificationKeys.game: game]
        NotificationCenter.default.post(name: .gameArchived, object: self, userInfo: notificationDict)
    }
}

// MARK: - Notification handling
private extension GameListViewController {
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(onNewGameCreated(_:)), name: .gameCreated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onGameEdited(_:)), name: .gameEdited, object: nil)
    }
    
    @objc private func onNewGameCreated(_ notification: NSNotification) {
        if let game = notification.userInfo?[Constants.NotificationKeys.game] as? Game {
            games.append(game)
            activeGamesTableView.insertRows(at: [IndexPath(row: games.count - 1, section: 0)], with: .middle)
            activeGamesTableView.selectRow(at: IndexPath(row: games.count - 1, section: 0), animated: true, scrollPosition: .middle)
            performSegue(withIdentifier: Constants.SegueIds.game, sender: self)
            tabBarController?.selectedIndex = 0
        }
    }
    
    @objc private func onGameEdited(_ notification: NSNotification) {
        activeGamesTableView.reloadData()
    }

}
