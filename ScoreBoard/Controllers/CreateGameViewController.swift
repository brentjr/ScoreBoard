//
//  CreateGameViewController.swift
//  ScoreBoard
//
//  Created by Brent Roberts on 1/1/18.
//  Copyright © 2018 Gouda Labs. All rights reserved.
//

import UIKit

class CreateGameViewController: UIViewController {
    
    var game: Game?
    
    private let editGameTitleText = "Edit Game"
    private let newGameTitleText = "New Game"
    private let editGameBackButtonText = "Back"
    private let newGameBackButtonText = "Cancel"
    private let playersTableRowHeight = 44
    
    private var isNewGame = true
    @IBOutlet private weak var backButton: UIBarButtonItem!
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var playersTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var playersTableView: UITableView!
    @IBOutlet private weak var addPlayerTextField: UITextField!
    @IBOutlet private weak var addPlayerButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    private func setPlayersTableViewConstraints() {
        if let players = game?.players {
            playersTableViewHeightConstraint.constant = CGFloat(playersTableRowHeight * players.count)
        } else {
            playersTableViewHeightConstraint.constant = 0
        }
    }
}

// MARK: - View lifecycle
extension CreateGameViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playersTableView.dataSource = self
        setPlayersTableViewConstraints()
        
        if let game = game {
            title = editGameTitleText
            isNewGame = false
            navigationItem.rightBarButtonItem = nil
            backButton.title = editGameBackButtonText
            titleTextField.text = game.title
        } else {
            title = newGameTitleText
            backButton.title = newGameBackButtonText
            game = GameService.shared.emptyGame()
        }
        
        addNotificationObservers()
    }
}

// MARK: - EditPlayersTableViewCellDelegate
extension CreateGameViewController: EditPlayersTableViewCellDelegate {
    
    func removePlayerBtnTapped(cell: EditPlayersTableViewCell) {
        guard let game = game, let players = game.players else {
            return
        }
        
        let indexPath = playersTableView.indexPath(for: cell)
        let mutable = players.mutableCopy() as! NSMutableSet
        mutable.remove(players.allObjects[indexPath!.row])
        game.players = (mutable.copy() as! NSSet)
        playersTableView.deleteRows(at: [indexPath!], with: .automatic)
        setPlayersTableViewConstraints()
    }
}

// MARK: - UITableViewDataSource
extension CreateGameViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let players = game?.players else {
            return 0
        }
        
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIds.createGamePlayersTable) as! EditPlayersTableViewCell
        
        if let player = game?.players?.allObjects[indexPath.row] as? Player {
            cell.player = player
            cell.delegate = self
            return cell
        } else {
            cell.player = nil
            return cell
        }
    }
}


// MARK: - IBActions
private extension CreateGameViewController {
    
    @IBAction private func cancelButtonPressed(_ sender: Any) {
        if !isNewGame, let game = game, let title = titleTextField.text {
            game.title = title
            GameService.shared.saveGame(game)
            
            let notificationDict: [String: Game] = [Constants.NotificationKeys.game: game]
            NotificationCenter.default.post(name: .gameEdited, object: self, userInfo: notificationDict)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func startButtonPressed(_ sender: Any) {
        guard isNewGame, let game = game, let title = titleTextField.text else {
            return
        }
        
        game.title = title
            
        let notificationDict: [String: Game] = [Constants.NotificationKeys.game: GameService.shared.insertGame(game)]
        NotificationCenter.default.post(name: .gameCreated, object: self, userInfo: notificationDict)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func addPlayerButtonPressed(_ sender: Any) {
        guard let game = game, let playerName = addPlayerTextField.text, isValid(playerName: playerName) else {
            return
        }
        
        if isNewGame {
            let player = GameService.shared.emptyPlayer()
            player.name = playerName
            game.addToPlayers(player)
        } else {
            GameService.shared.createPlayer(name: playerName, for: game)
        }
        
        playersTableView.reloadData()
        setPlayersTableViewConstraints()
        
        addPlayerTextField.text = ""
        addPlayerTextField.resignFirstResponder()
    }
}

// MARK: - User input validation
private extension CreateGameViewController {
    
    func isValid(playerName: String) -> Bool {
        if playerName.isEmpty {
            return false
        }
        if playerName.trimmingCharacters(in: .whitespaces).isEmpty {
            return false
        }
        return true
    }
}

// MARK: - Keyboard notification handling
private extension CreateGameViewController {
    
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    @objc private func onKeyboardShown(notification: NSNotification) {
        //Need to calculate keyboard exact size due to Apple suggestions
        scrollView.isScrollEnabled = true
        let info = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
    }
}
