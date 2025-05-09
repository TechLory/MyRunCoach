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
    
    
    @StateObject private var cameraModel = CameraModel()
    @State private var mlModel = PostureClassifierModel()
    @State private var actionLabel = "No body recognized"
    @State private var actionLabels: [String:Double] = [:]
    
    @StateObject private var speechManager = PostureSpeechManager()
    
    
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
    
    
    /// Main App View
    var mainView: some View {
        VStack {
            /// Real-time suggestions Box
            HStack {
                Text(formattedLabel(label: actionLabel))
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .foregroundStyle((actionLabel == "correct") ? .white : .red)
                Spacer()
            }
            .padding(.top, 80)
            
            GeometryReader { geometry in
                let width = geometry.size.width
                let aspectRatio: CGFloat = 4 / 3 // (.photo)
    
                VStack {
                    /// Camera Preview
                    cameraPreviewFrame(width: width, aspectRatio: aspectRatio)
                    /// Play Button and Crono
                    /*
                    HStack {
                        startStopButton
                        if (isRunningAnalysis) {
                            stopWatch
                        }
                    }*/
                    /// DEBUG print all classes
                    debugPrintAllLabels
                }
            }
            Spacer()
        }
        .speechModifiers(
            label: actionLabel,
            isActive: isRunningAnalysis,
            speechManager: speechManager
        )
    }
    
    private var debugPrintAllLabels: some View {
        VStack() {
            ForEach(Array(actionLabels), id: \.key) { key, value in
                HStack {
                    Text("\(key):").bold()
                    Spacer()
                    Text(String(format: "%.2f", value))
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func formattedLabel(label: String) -> String {
        switch label {
        case "correct":
            return "Correct"
        case "incorrect_head_down":
            return "Incorrect: Head Down"
        case "incorrect_head_up":
            return "Incorrect: Head Up"
        case "incorrect_shoulders_back":
            return "Incorrect: Shoulders Back"
        case "incorrect_shoulders_forward":
            return "Incorrect: Shoulders Forward"
        case "static":
            return "Static"
        default:
            return "No body recognized"
        }
    }
    
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
            actionLabel = mlModel.predict(poses: cameraModel.keypointsBuffer)?
                .max(by: { $0.value < $1.value })?.key ?? ""
            actionLabels = mlModel.predict(poses: cameraModel.keypointsBuffer) ?? [:]
        }
    }
    
    private var startStopButton: some View {
        Button(isRunningAnalysis ? "Stop" : "Start") {
            if (isRunningAnalysis) {
                // Stop
                timerManager.reset()
                speechManager.stop()
                isRunningAnalysis = false
            } else {
                // Start
                timerManager.start()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    isRunningAnalysis = true
                }
            }
        }
        .frame(maxWidth: .infinity)
        .font(.title2)
        .fontWeight(.bold)
        .padding()
        .foregroundStyle(.black)
        .background() {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(isRunningAnalysis ? .red : Color.accentColor)
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
    }
    
    private var stopWatch: some View {
        Text(formattedTime(timerManager.timeElapsed))
            .font(.title)
            .fontWeight(.bold)
            .monospaced()
            .padding(.trailing)
    }
    
    private func formattedTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let deci = Int((time - Double(Int(time))) * 10)
        return String(format: "%02d:%02d.%d", minutes, seconds, deci)
    }
    
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
