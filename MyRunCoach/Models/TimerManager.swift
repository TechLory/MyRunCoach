//
//  TimerManager.swift
//  MyRunCoach
//
//  Created by Lorenzo Gatta on 12/04/25.
//

import Foundation
import Combine
import AVFAudio

class TimerManager: ObservableObject {
    
    @Published var timeElapsed: Double = 0.0
    @Published var isRunning = false

    private var timer: AnyCancellable?
    private var player: AVAudioPlayer?

    func start() {
        guard !isRunning else { return }
        isRunning = true
        
        playSound(named: "countdown")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.timer = Timer.publish(every: 0.1, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    self.timeElapsed += 0.1
                }
        }
    }

    func pause() {
        isRunning = false
        timer?.cancel()
    }

    func reset() {
        pause()
        timeElapsed = 0.0
    }
    
    private func playSound(named name: String) {
        if let url = Bundle.main.url(forResource: name, withExtension: "mp3") {
            player = try? AVAudioPlayer(contentsOf: url)
            player?.volume = 0.7
            player?.play()
        }
    }
}
