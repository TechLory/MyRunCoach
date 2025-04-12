//
//  HumanBodyPoseDetectionModel.swift
//  PostureClassifier2
//
//  Created by Lorenzo Gatta on 23/03/25.
//

import Foundation
import AVFoundation
import Vision



extension CameraModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    
    

    // This function takes the camera stream and performs the human body pose detection.
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Error on pixelBuffer")
            return
        }
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        let request = VNDetectHumanBodyPoseRequest()
        
        do {
            try requestHandler.perform([request])
            guard let observation = request.results?.first else { return }
            
            let orderedKeys: [VNHumanBodyPoseObservation.JointName] = [
                .nose, .neck,
                .rightShoulder, .rightElbow, .rightWrist,
                .leftShoulder, .leftElbow, .leftWrist,
                .rightHip, .rightKnee, .rightAnkle,
                .leftHip, .leftKnee, .leftAnkle,
                .rightEye, .leftEye, .rightEar, .leftEar
            ]
            
            var frameData: [[Float]] = []
            for key in orderedKeys {
                guard let point = try? observation.recognizedPoint(key) else {
                    frameData.append([0, 0, 0])
                    continue
                }
                frameData.append([Float(point.x), Float(point.y), Float(point.confidence)])
            }
            
            DispatchQueue.main.async {
                self.currentKeypoints = observation.availableJointNames.reduce(into: [:]) {
                    $0[$1] = try? observation.recognizedPoint($1)
                }
                self.updateBuffer(with: frameData)
            }
        } catch { print("Error on captureOutput") }
    }


    
    
    // This function takes a frame (matrix) and adds it to the circular buffer,
    // removing the oldest (first) frame if maximum size is reached.
    private func updateBuffer(with frame: [[Float]]) {
        keypointsBuffer.append(frame)
        if keypointsBuffer.count > 60 { keypointsBuffer.removeFirst() }
        bufferReady = keypointsBuffer.count == 60
    }
    
    
    
    
    
    
    
    
    
}





