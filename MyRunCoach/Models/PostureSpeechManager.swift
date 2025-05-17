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
    
    
    
    
    // debug audio
    init() {
        configureAudioSession()
    }

    private func configureAudioSessionDeprecated() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio configuration error: \(error.localizedDescription)")
        }
    }
    
    
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
                .playAndRecord,
                mode: .default,
                options: [.mixWithOthers, .defaultToSpeaker, .allowBluetoothA2DP]
            )
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            print("Audio configurato con successo")
        } catch {
            print("Errore audio: \(error.localizedDescription)")
        }
    }
    
    
}
