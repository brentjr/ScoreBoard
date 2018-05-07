//
//  TimerViewController.swift
//  ScoreBoard
//
//  Created by Brent Roberts on 5/7/18.
//  Copyright © 2018 Gouda Labs. All rights reserved.
//
import AVFoundation
import UIKit

class TimerViewController: UIViewController {

    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var timerLabel: UILabel!
    @IBOutlet private weak var timePicker: UIPickerView!

    private var seconds = 0
    private var timer = Timer()
    private var isTimerRunning = false
    private var isPaused = false

    override func viewDidLoad() {
        super.viewDidLoad()
        timePicker.dataSource = self
        timePicker.delegate = self
        reset()
    }
}

// MARK: - UIPickerViewDataSource
extension TimerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 59
    }
}

// MARK: - UIPickerViewDelegate
extension TimerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(row) min"
        } else {
            return "\(row) sec"
        }
    }
}

// MARK: - IBActions
extension TimerViewController {

    @IBAction func startButtonTapped(_ sender: UIButton) {
        if isTimerRunning {
            pause()
        } else {
            start()
        }
    }

    @IBAction func resetButtonTapped(_ sender: UIButton) {
        if isTimerRunning {
            reset()
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

private extension TimerViewController {

    private func start() {
        if !isPaused {
            seconds = (timePicker.selectedRow(inComponent: 0) * 60) + timePicker.selectedRow(inComponent: 1)
            timerLabel.text = timeString(time: TimeInterval(seconds))
        } else {
            isPaused = false
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
        startButton.setTitle("Pause", for: .normal)
        timePicker.isHidden = true
        timerLabel.isHidden = false
    }

    private func pause() {
        timer.invalidate()
        isPaused = true
        isTimerRunning = false
        startButton.setTitle("Resume", for: .normal)
    }

    private func reset() {
        timer.invalidate()
        timerLabel.text = timeString(time: TimeInterval(0))
        isPaused = false
        isTimerRunning = false
        startButton.setTitle("Start", for: .normal)
        timePicker.isHidden = false
        timerLabel.isHidden = true
    }

    @objc private func updateTimer() {
        seconds -= 1
        timerLabel.text = timeString(time: TimeInterval(seconds))

        if seconds < 1 {
            timer.invalidate()
            let systemSoundID: SystemSoundID = 1304
            AudioServicesPlaySystemSound(systemSoundID)
            reset()
        }
    }

    private func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
}
