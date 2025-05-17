//
//  CameraModel.swift
//  PostureClassifier2
//
//  Created by Lorenzo Gatta on 23/03/25.
//

import Foundation
import AVFoundation
import Vision



class CameraModel: NSObject, ObservableObject {
    
    let captureSession = AVCaptureSession()
    @Published var isLoading = true
    @Published var isAuthorizationDenied = false
    @Published var currentKeypoints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint] = [:]
    @Published var keypointsBuffer: [[[Float]]] = []
    @Published var bufferReady = false
    private let videoOutput = AVCaptureVideoDataOutput()
    private let queue = DispatchQueue(label: "camera.queue")
    var isProcessingFrame = false
    let desiredFPS: Int32 = 30 // FRAME RATE OF THE MODEL
    let modelActionDuration: Int32 = 2 // ACTION DURATION OF THE MODEL
    
    
    override init() {
        super.init()
        self.cameraPermissions()
    }
    
    
    
    
    // Checks the permissions for the camera.
    private func cameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: cameraStartUp()
        case .notDetermined: requestAccess()
        default: break
        }
    }
    
    
    
    
    // Requests access to the camera.
    private func requestAccess() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted { self.cameraStartUp() } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isAuthorizationDenied = true
                }
            }
        }
    }
    
    
    
    
    // Sets up the camera input.
    private func cameraStartUp() {
        
        DispatchQueue.main.async {
            self.isAuthorizationDenied = false
        }
        self.captureSession.sessionPreset = .photo
        
        
        
        /// Gets the device
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        /// Custom Frame Rate and Shutter Speed (for efficiency).
        do {
            try captureDevice.lockForConfiguration()
            
            /// Frame rate
            captureDevice.activeVideoMinFrameDuration = CMTime(value: 1, timescale: desiredFPS)
            captureDevice.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: desiredFPS)
            
            /// Shutter
            let shutterDuration = CMTime(value: 1, timescale: 100) /// time: 1/100
            let currentISO = captureDevice.iso
            captureDevice.setExposureModeCustom(duration: shutterDuration, iso: currentISO, completionHandler: nil)
            
            captureDevice.unlockForConfiguration()
        } catch {
            print("Error in lockForConfig: \(error)")
        }
        
        
        
        /// Gets the input from the device
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        ///  Adds input to session
        if self.captureSession.canAddInput(input) {
            self.captureSession.addInput(input)
        }
        
        /// Sets sample buffer delegate
        self.videoOutput.setSampleBufferDelegate(self, queue: queue)
        
        /// Adds output to session
        if self.captureSession.canAddOutput(videoOutput) {
            self.captureSession.addOutput(videoOutput)
        }
        
        /// Starts the session (background thread)
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    
    
    
}
