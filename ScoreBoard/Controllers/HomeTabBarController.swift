//
//  CustomTabBarController.swift
//  ScoreBoard
//
//  Created by Brent Roberts on 12/31/17.
//  Copyright © 2017 Gouda Labs. All rights reserved.
//

import UIKit

class HomeTabBarController: UITabBarController {
    
    private var newGameButton: UIButton?
    private var shouldHideButton = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNewGameButton()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        //TODO: make this look nice
        coordinator.animate(alongsideTransition: nil, completion: { _ in
            self.setupNewGameButton()
        })
    }
    
    func hide() {
        tabBar.isHidden = true
        shouldHideButton = true
        if let newGameButton = newGameButton {
            newGameButton.removeFromSuperview()
        }
    }
    
    func show() {
        tabBar.isHidden = false
        shouldHideButton = false
        if let newGameButton = newGameButton {
            view.addSubview(newGameButton)
        }
    }
    
    private func setupNewGameButton() {
        if shouldHideButton == true {
            return
        }
        
        if let newGameButton = newGameButton {
            newGameButton.removeFromSuperview()
        }
        
        let tabHeight = tabBar.frame.size.height

        newGameButton = UIButton(frame: CGRect(x: 0, y: 0, width: tabHeight * 0.75, height: tabHeight * 0.75))
        
        var newGameButtonFrame = newGameButton!.frame
        newGameButtonFrame.origin.y = view.bounds.height - (tabHeight / 2) - (newGameButtonFrame.size.height / 2)
        newGameButtonFrame.origin.x = (view.bounds.width / 2) - (newGameButtonFrame.size.width / 2)
        newGameButton!.frame = newGameButtonFrame
        
        newGameButton!.tintColor = UIColor.lightGray
        newGameButton!.backgroundColor = UIColor.white
        newGameButton!.layer.borderColor = view.tintColor.cgColor
        newGameButton!.layer.borderWidth = 2
        newGameButton!.layer.cornerRadius = newGameButtonFrame.height / 2
        
        newGameButton!.setImage(UIImage(named: "plus-icon"), for: UIControlState.normal)
        newGameButton!.contentMode = .center
        newGameButton!.imageView?.contentMode = .scaleAspectFit
        
        newGameButton!.addTarget(self, action: #selector(newGameButtonPressed), for: UIControlEvents.touchUpInside)
        
        view.addSubview(newGameButton!)
    }
}

//MARK: - IBActions
extension HomeTabBarController {
    
    @objc private func newGameButtonPressed(sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createGameModal")
        vc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        present(vc, animated: true, completion: nil)
    }
}
