//
//  MainScreen.swift
//  MyRunCoach
//
//  Created by Lorenzo Gatta on 30/03/25.
//

import SwiftUI
import AVFAudio

struct MainScreen: View {
    
    private var synthesizer = AVSpeechSynthesizer()
    @StateObject private var timerManager = TimerManager()
    
    @State private var showWelcomeScreen = true
    @State private var isRunningAnalysis = false
    @State private var isWaiting = false
    
    @StateObject private var cameraModel = CameraModel()
    @State private var mlModel = PostureClassifierModel()
    @State private var actionLabel = "No body recognized"
    @State private var actionLabels: [String:Double] = [:]
    
    @StateObject private var speechManager = PostureSpeechManager()
    
    // Body
    var body: some View {
        ZStack {
            if showWelcomeScreen {
                WelcomeScreen(isVisible: $showWelcomeScreen)
            } else {
                background
                mainView
            }
        }
        .preferredColorScheme(.dark)
    }
    
    
    // Main App View
    var mainView: some View {
        VStack {
            /// Real-time suggestions Box
            HStack {
                /// Dinamic style Label
                formattedLabel(label: actionLabel)
                Spacer()
            }
            .padding(.top, 80)
            
            GeometryReader { geometry in
                let width = geometry.size.width
                let aspectRatio: CGFloat = 4 / 3 /// (.photo)
    
                VStack {
                    /// Camera Preview
                    cameraPreviewFrame(width: width, aspectRatio: aspectRatio)
                    /// Play Button and Crono
                    
                    HStack {
                        startStopButton
                        if (isRunningAnalysis) {
                            stopWatch
                        }
                    }
                    /// DEBUG print all classes
                    //debugPrintAllLabels
                }
            }
            Spacer()
        }
        .speechModifiers(
            label: cleanLabel(label: actionLabel),
            isActive: isRunningAnalysis,
            speechManager: speechManager
        )
    }
    
    private func cleanLabel(label: String) -> String {
        if label.hasPrefix("incorrect_") {
            return String(label.dropFirst(10))
        }
        return label
    }
    
    // DEBUG
    private var debugPrintAllLabels: some View {
        VStack() {
            ForEach(actionLabels.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                HStack {
                    Text("\(key):").bold()
                        .foregroundStyle((key == actionLabels.max{ $0.value < $1.value }?.key) ? .red : .white)
                    Spacer()
                    Text(String(format: "%.2f", value))
                        .foregroundStyle((key == actionLabels.max{ $0.value < $1.value }?.key) ? .red : .white)
                }
            }
        }
        .padding(.horizontal)
    }
    
    // Generate Text for current label.
    private func formattedLabel(label: String) -> some View {
        var textColor = Color.yellow
        var text = "No body recognized"
        switch label {
        case "correct":
            text = "Correct"
            textColor = Color.accent
        case "incorrect_head_down":
            text = "Head Down"
            textColor = Color.red
        case "incorrect_head_up":
            text = "Head Up"
            textColor = Color.red
        case "incorrect_shoulders_back":
            text = "Shoulders Back"
            textColor = Color.red
        case "incorrect_shoulders_forward":
            text = "Shoulders Forward"
            textColor = Color.red
        case "static":
            text = "Static"
            textColor = Color.yellow
        default:
            text = "No body recognized"
        }
        return Text(text)
            .font(.title2)
            .fontWeight(.bold)
            .padding(.horizontal)
            .foregroundStyle(textColor)
    }
    
    
    // If user gave the permission shows the camera preview and the skeleton, shows an error otherwise.
    // Computes the cameraModel prediction.
    private func cameraPreviewFrame(width: CGFloat, aspectRatio: CGFloat) -> some View {
        ZStack {
            Color(.noCameraBackground)
            VStack {
                Image(systemName: "video.slash.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.gray)
                Text("Please, give the permission to access the camera.")
                    .padding()
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .fontWeight(.semibold)
            }
            CameraRepresentable(session: cameraModel.captureSession)
                .frame(width: width, height: width * aspectRatio)
                .clipped()
            HumanBodySkeletonView(keypoints: cameraModel.currentKeypoints)
        }
        .frame(width: width, height: width * aspectRatio)
        .onReceive(cameraModel.$bufferReady) { ready in
            guard ready else { return }
            mlModel.predict(poses: cameraModel.keypointsBuffer) { result in
                guard let result = result else { return }
                self.actionLabels = result
                self.actionLabel = result.max(by: { $0.value < $1.value })?.key ?? ""
            }
        }
    }
    
    // Returns the start/stop analysis button.
    private var startStopButton: some View {
        Button(action: {
            if (isRunningAnalysis) {
                // Stop
                timerManager.reset()
                speechManager.stop()
                isRunningAnalysis = false
            } else {
                // Start
                isWaiting = true
                timerManager.start()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    isRunningAnalysis = true
                    isWaiting = false
                }
            }
        }) {
            Text(isRunningAnalysis ? "Stop" : (isWaiting ? "Starting..." : "Start"))
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
        }
        .disabled(isWaiting)
        .frame(maxWidth: .infinity)
        .font(.title2)
        .fontWeight(.bold)
        .foregroundStyle(.black)
        .padding()
        .background() {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(isRunningAnalysis ? .red : (isWaiting ? Color.accentColorDisabled : Color.accent))
        }
        .contentShape(Rectangle())
        .padding(.vertical, 8)
        .padding(.horizontal)
    }
    
    // Stops and resets the crono.
    private var stopWatch: some View {
        Text(formattedTime(timerManager.timeElapsed))
            .font(.title)
            .fontWeight(.bold)
            .monospaced()
            .padding(.trailing)
    }
    
    // Returns formatted time of the crono.
    private func formattedTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let deci = Int((time - Double(Int(time))) * 10)
        return String(format: "%02d:%02d.%d", minutes, seconds, deci)
    }
    
    // Returns the background of the main view.
    private var background: some View {
        ZStack {
            VStack {
                Circle()
                    .fill(.green)
                    .scaleEffect(0.6)
                    .offset(x: 20)
                    .blur(radius: 120)
                Circle()
                    .fill(.red)
                    .scaleEffect(0.6, anchor: .leading)
                    .blur(radius: 120)
            }
            Rectangle()
                .fill(.ultraThinMaterial)
        }
        .ignoresSafeArea()
    }
}


extension View {
    
    // Manages the speech synth.
    func speechModifiers(label: String, isActive: Bool, speechManager: PostureSpeechManager) -> some View {
        self
            .onChange(of: label) { _, newValue in
                guard isActive else { return }
                speechManager.handleNewLabel(newValue)
            }
            .onChange(of: isActive) { _, newValue in
                if !newValue {
                    speechManager.stop()
                }
            }
            .onDisappear {
                speechManager.stop()
            }
    }
}


#Preview {
    MainScreen()
}
