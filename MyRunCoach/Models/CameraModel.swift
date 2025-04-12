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
        
        
        
        /// 2 - Gets the device
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        /// 3 - Gets the input from the device
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        /// 4 - Adds input to session
        if self.captureSession.canAddInput(input) {
            self.captureSession.addInput(input)
        }
        /// 5 - Sets sample buffer delegate
        self.videoOutput.setSampleBufferDelegate(self, queue: queue)
        /// 6 - Adds output to session
        if self.captureSession.canAddOutput(videoOutput) {
            self.captureSession.addOutput(videoOutput)
        }
        /// 7 - Starts the session (background thread?)
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    
    
    
}
