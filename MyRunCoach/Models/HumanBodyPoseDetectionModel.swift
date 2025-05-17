//
//  HumanBodyPoseDetectionModel.swift
//  PostureClassifier2
//
//  Created by Lorenzo Gatta on 23/03/25.
//

import Foundation
import AVFoundation
import Vision
import UIKit

func exifOrientation(from deviceOrientation: UIDeviceOrientation) -> CGImagePropertyOrientation {
    switch deviceOrientation {
    case .portrait:           return .right
    case .portraitUpsideDown: return .left
    case .landscapeLeft:      return .up
    case .landscapeRight:     return .down
    default:                  return .up
    }
}

extension CameraModel: AVCaptureVideoDataOutputSampleBufferDelegate {

    // This function takes the camera stream and performs the human body pose detection.
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard !isProcessingFrame else { return }
        isProcessingFrame = true        
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            isProcessingFrame = false
            print("Error on pixelBuffer")
            return
        }
        
        // Dinamic Orientation
        let uiOri = UIDevice.current.orientation
        let vnOri = exifOrientation(from: uiOri)
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: vnOri)
        let request = VNDetectHumanBodyPoseRequest()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                try requestHandler.perform([request])
                guard let observation = request.results?.first else {
                    DispatchQueue.main.async {
                        self?.isProcessingFrame = false
                    }
                    return
                }

                let orderedKeys: [VNHumanBodyPoseObservation.JointName] = [
                    .nose, .neck, .rightShoulder, .rightElbow, .rightWrist,
                    .leftShoulder, .leftElbow, .leftWrist, .rightHip, .rightKnee, .rightAnkle,
                    .leftHip, .leftKnee, .leftAnkle, .rightEye, .leftEye, .rightEar, .leftEar
                ]

                var frameData: [[Float]] = []
                for key in orderedKeys {
                    let point = try? observation.recognizedPoint(key)
                    frameData.append([Float(point?.x ?? 0), Float(point?.y ?? 0), Float(point?.confidence ?? 0)])
                }

                DispatchQueue.main.async {
                    self?.currentKeypoints = observation.availableJointNames.reduce(into: [:]) {
                        $0[$1] = try? observation.recognizedPoint($1)
                    }
                    self?.updateBuffer(with: frameData)
                    self?.isProcessingFrame = false
                }
            } catch {
                DispatchQueue.main.async {
                    self?.isProcessingFrame = false
                }
                print("Error on captureOutput0002")
            }
        }
    }


    
    
    // This function takes a frame (matrix) and adds it to the circular buffer,
    // removing the oldest (first) frame if maximum size is reached.
    private func updateBuffer(with frame: [[Float]]) {
        keypointsBuffer.append(frame)
        if keypointsBuffer.count > (desiredFPS * modelActionDuration) { keypointsBuffer.removeFirst() }
        bufferReady = keypointsBuffer.count == (desiredFPS * modelActionDuration)
    }
    
    
    
    
    
    
    
    
    
}





