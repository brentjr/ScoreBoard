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
    private var playersTableRowHeight: CGFloat {
        get {
            return 44
        }
    }

    private var isNewGame = true
    @IBOutlet private weak var backButton: UIBarButtonItem!
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var playersTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var playersTableView: UITableView!
    @IBOutlet private weak var addPlayerTextField: UITextField!
    @IBOutlet private weak var addPlayerButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var playerOrderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var winConditionSegmentedControl: UISegmentedControl!

    private func setPlayersTableViewConstraints() {
        if let players = game?.players {
            playersTableViewHeightConstraint.constant = playersTableRowHeight * CGFloat(players.count)
        } else {
            playersTableViewHeightConstraint.constant = 0
        }
    }
}

// MARK: - View lifecycle
extension CreateGameViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.isScrollEnabled = true

        playersTableView.dataSource = self
        setPlayersTableViewConstraints()

        if let game = game {
            title = editGameTitleText
            isNewGame = false
            navigationItem.rightBarButtonItem = nil
            backButton.title = editGameBackButtonText
            titleTextField.text = game.title
            playerOrderSegmentedControl.selectedSegmentIndex = Int(game.playerDisplayOrder)
            winConditionSegmentedControl.selectedSegmentIndex = Int(game.winCondition)
        } else {
            title = newGameTitleText
            backButton.title = newGameBackButtonText
            game = GameService.shared.emptyGame()
            game!.playerDisplayOrder = Int16(playerOrderSegmentedControl.selectedSegmentIndex)
            game!.winCondition = Int16(winConditionSegmentedControl.selectedSegmentIndex)
        }

        addNotificationObservers()
    }
}

// MARK: - UITableViewDataSource
extension CreateGameViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return game?.players?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIds.createGamePlayersTable) as! EditPlayersTableViewCell

        if let player = game?.players?.allObjects[indexPath.row] as? Player {
            cell.player = player
            cell.delegate = self
        } else {
            cell.player = nil
            cell.delegate = nil
        }

        return cell
    }
}

// MARK: - EditPlayersTableViewCellDelegate
extension CreateGameViewController: EditPlayersTableViewCellDelegate {
    
    func removePlayerBtnTapped(cell: EditPlayersTableViewCell) {
        guard let game = game, let players = game.players else {
            return
        }
        
        let alert = UIAlertController(title: "Are you sure?", message: "User scores will be deleted forever.", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action: UIAlertAction!) in
            let indexPath = self.playersTableView.indexPath(for: cell)
            let mutable = players.mutableCopy() as! NSMutableSet
            mutable.remove(players.allObjects[indexPath!.row])
            game.players = (mutable.copy() as! NSSet)
            self.playersTableView.deleteRows(at: [indexPath!], with: .automatic)
            self.setPlayersTableViewConstraints()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
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
    
    @IBAction private func playerOrderSegmentedControlChanged(_ sender: Any) {
        guard let game = game else {
            return
        }
        game.playerDisplayOrder = Int16(playerOrderSegmentedControl.selectedSegmentIndex)
    }
    
    @IBAction private func winConditionSegmentedControlChanged(_ sender: Any) {
        guard let game = game else {
            return
        }
        game.winCondition = Int16(winConditionSegmentedControl.selectedSegmentIndex)
    }
}

// MARK: - User input validation
private extension CreateGameViewController {
    
    private func isValid(playerName: String) -> Bool {
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
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc private func onKeyboardShown(notification: NSNotification) {
        let info = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height + CGFloat(10), 0.0)
        
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect: CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
    }
    
    @objc private func onKeyboardHide(notification: NSNotification) {
        let info = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect: CGRect = self.view.frame
        aRect.size.height += keyboardSize!.height
    }
}
