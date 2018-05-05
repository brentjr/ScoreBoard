//
//  ActiveGameWinnerView.swift
//  ScoreBoard
//
//  Created by Brent Roberts on 1/9/18.
//  Copyright © 2018 Gouda Labs. All rights reserved.
//

import UIKit
import QuartzCore

class GameWinnerView: UIView {
    
    private let height: CGFloat = 50
    private let colors = [
        UIColor(red:0.95, green:0.40, blue:0.27, alpha:1.0),
        UIColor(red:1.00, green:0.78, blue:0.36, alpha:1.0),
        UIColor(red:0.48, green:0.78, blue:0.64, alpha:1.0),
        UIColor(red:0.30, green:0.76, blue:0.85, alpha:1.0),
        UIColor(red:0.58, green:0.39, blue:0.55, alpha:1.0)]
    private let intensity: Float = 0.5
    
    private var emitter: CAEmitterLayer!

    @IBOutlet private weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var winnerNameLabel: UILabel!
}

extension GameWinnerView {
    
    public func setWinner(name: String, animated: Bool) {
        setVisible(true, animated: animated)
        winnerNameLabel.text = "Winner: \(name)"
        if animated {
            startConfetti()
        }
    }
    
    public func hide(animated: Bool) {
        setVisible(false, animated: animated)
        winnerNameLabel.text = ""
        stopConfetti()
    }
}

extension GameWinnerView {
    
    private func setVisible(_ show: Bool, animated: Bool) {
        heightConstraint.constant = show ? self.height : 0
    }
    
    private func startConfetti() {
        emitter = CAEmitterLayer()
        
        emitter.emitterPosition = CGPoint(x: frame.size.width / 2.0, y: 0)
        emitter.emitterShape = kCAEmitterLayerLine
        
        var cells = [CAEmitterCell]()
        for color in colors {
            cells.append(confettiWithColor(color: color))
        }
        
        emitter.emitterCells = cells
        superview?.layer.addSublayer(emitter)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.emitter.birthRate = 0.0
        }
    }
    
    private func stopConfetti() {
        emitter?.birthRate = 0.0
        emitter?.removeFromSuperlayer()
    }
    
    private func confettiWithColor(color: UIColor) -> CAEmitterCell {
        let confetti = CAEmitterCell()
        confetti.birthRate = 6.0 * intensity
        confetti.lifetime = 14.0 * intensity
        confetti.lifetimeRange = 0
        confetti.color = color.cgColor
        confetti.velocity = CGFloat(350.0 * intensity)
        confetti.velocityRange = CGFloat(80.0 * intensity)
        confetti.emissionLongitude = CGFloat(Double.pi)
        confetti.emissionRange = CGFloat(Double.pi)
        confetti.spin = CGFloat(3.5 * intensity)
        confetti.spinRange = CGFloat(4.0 * intensity)
        confetti.scaleRange = CGFloat(intensity)
        confetti.scaleSpeed = CGFloat(-0.1 * intensity)
        confetti.contents = UIImage(named: "confetti")?.cgImage
        return confetti
    }
}
