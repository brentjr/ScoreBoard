//
//  ItemTwoViewController.swift
//  ScoreBoard
//
//  Created by Brent Roberts on 12/30/17.
//  Copyright © 2017 Gouda Labs. All rights reserved.
//

import UIKit

class ArchivedGamesViewController: UIViewController {
    
    private var games: [Game] = []
    @IBOutlet private weak var archivedGamesTableView: UITableView!
}

// MARK: - View lifecycle
extension ArchivedGamesViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        archivedGamesTableView.dataSource = self
        archivedGamesTableView.delegate = self
        
        games = GameService.shared.archivedGames()
        archivedGamesTableView.reloadData()
        
        addNotificationObservers()
    }
}

// MARK: - UITableViewDataSource
extension ArchivedGamesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "oranges")
        cell?.textLabel?.text = games[indexPath.row].title
        return cell!
    }
}

// MARK: - UITableViewDelegate
extension ArchivedGamesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, index) in
            self.tableView(tableView, deleteItemAt: indexPath)
        }
        
        let reactivate = UITableViewRowAction(style: .normal, title: "Re-activate") { (action, index) in
            self.tableView(tableView, reactivateItemAt: indexPath)
        }
        
        return [reactivate, delete]
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
            self.tableView(tableView, deleteItemAt: indexPath)
        }
        
        let reactivate = UIContextualAction(style: .normal, title: "Re-activate") { (action, sourceView, completionHandler) in
            self.tableView(tableView, reactivateItemAt: indexPath)
        }
        
        let swipeAction = UISwipeActionsConfiguration(actions: [reactivate, delete])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
    }
    
    private func tableView(_ tableView: UITableView, deleteItemAt indexPath: IndexPath) {
        let refreshAlert = UIAlertController(title: "Delete", message: "Game will be deleted permanently.", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            GameService.shared.deleteGame(self.games[indexPath.row])
            self.games.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            //TODO: Should work but doesnt
            //tableView.setEditing(false, animated: true)
            tableView.reloadData()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            //TODO: Should work but doesnt
            //tableView.setEditing(false, animated: true)
            tableView.reloadData()
        }))
        tableView.isEditing = false
        present(refreshAlert, animated: true, completion: nil)
    }
    
    private func tableView(_ tableView: UITableView, reactivateItemAt indexPath: IndexPath) {
        let game = self.games[indexPath.row]
        game.isArchived = false
        GameService.shared.saveGame(game)
        
        self.games.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.setEditing(false, animated: true)
        
        let notificationDict: [String: Game] = ["game": game]
        NotificationCenter.default.post(name: .gameReactivated, object: self, userInfo: notificationDict)
    }
}

// MARK: - Notification handling
private extension ArchivedGamesViewController {
    
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(onGameArchived(_:)), name: .gameArchived, object: nil);
    }
    
    @objc private func onGameArchived(_ notification: NSNotification) {
        if let game = notification.userInfo?["game"] as? Game {
            games.append(game)
            archivedGamesTableView.insertRows(at: [IndexPath(row: games.count - 1, section: 0)], with: .middle)
            archivedGamesTableView.reloadData()
        }
    }
}
