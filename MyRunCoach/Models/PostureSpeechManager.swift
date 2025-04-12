//
//  PostureSpeechManager.swift
//  MyRunCoach
//
//  Created by Lorenzo Gatta on 12/04/25.
//

import Foundation
import AVFoundation
import Combine

class PostureSpeechManager: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    private var lastSpokenLabel = ""
    private var debounceTimer: Timer?
    private let debounceInterval: TimeInterval = 0.6
    
    func handleNewLabel(_ label: String) {
        debounceTimer?.invalidate()
        
        debounceTimer = Timer.scheduledTimer(withTimeInterval: debounceInterval, repeats: false) { [weak self] _ in
            self?.speakIfNeeded(label)
        }
    }
    
    private func speakIfNeeded(_ label: String) {
        guard label != lastSpokenLabel else { return }
        
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: label)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        
        synthesizer.speak(utterance)
        lastSpokenLabel = label
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
