//
//  HumanBodySkeletonView.swift
//  PostureClassifier2
//
//  Created by Lorenzo Gatta on 23/03/25.
//

import SwiftUI
import Vision

struct HumanBodySkeletonView: View {
    
    var keypoints: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(keypoints.keys), id: \.self) { joint in
                    if let point = keypoints[joint], point.confidence > 0.1 {
                        Circle()
                            .frame(width: 10, height: 10)
                            .position(point.location(in: geometry.size))
                            .foregroundColor(.green)
                    }
                }
                drawConnections(in: geometry.size)
            }
            
        }
    }
    
    
    /*
     This function takes a distance vector (CGSize) and returns a
     view showing the connections between the points.
     */
     private func drawConnections(in size: CGSize) -> some View {
        let connections = BodyConnections.allCases
        return ZStack {
            ForEach(connections, id: \.self) { connection in
                Path { path in
                    guard
                        let start = keypoints[connection.start]?.location(in: size),
                        let end = keypoints[connection.end]?.location(in: size),
                        keypoints[connection.start]!.confidence > 0.1,
                        keypoints[connection.end]!.confidence > 0.1
                    else {
                        return
                    }
                    path.move(to: start)
                    path.addLine(to: end)
                }
                .stroke(.blue, lineWidth: 3)
            }
        }
    }
}




extension VNRecognizedPoint {
    
    /*
     This function takes the coordinates of the parent, via GeometryReader,
     and calculates the coordinates x and y based on the position of the parent and
     of the point itself, and returns them as a CGPoint.
     */
    func location(in size: CGSize) -> CGPoint {
        let mappedX = self.x * size.width
        let mappedY = (1 - self.y) * size.height
        return CGPoint(x: mappedX, y: mappedY)
    }
}




enum BodyConnections: CaseIterable {
    case neckNose, neckShoulderR, shoulderRElbowR, elbowRWristR
    case neckShoulderL, shoulderLElbowL, elbowLWristL
    case neckHipR, hipRKneeR, kneeRAnkleR
    case neckHipL, hipLKneeL, kneeLAnkleL
    
    var start: VNHumanBodyPoseObservation.JointName {
        switch self {
        case .neckNose: return .neck
        case .neckShoulderR, .neckShoulderL: return .neck
        case .shoulderRElbowR: return .rightShoulder
        case .elbowRWristR: return .rightElbow
        case .shoulderLElbowL: return .leftShoulder
        case .elbowLWristL: return .leftElbow
        case .neckHipR, .neckHipL: return .neck
        case .hipRKneeR: return .rightHip
        case .kneeRAnkleR: return .rightKnee
        case .hipLKneeL: return .leftHip
        case .kneeLAnkleL: return .leftKnee
        }
    }
    
    var end: VNHumanBodyPoseObservation.JointName {
        switch self {
        case .neckNose: return .nose
        case .neckShoulderR: return .rightShoulder
        case .neckShoulderL: return .leftShoulder
        case .shoulderRElbowR: return .rightElbow
        case .elbowRWristR: return .rightWrist
        case .shoulderLElbowL: return .leftElbow
        case .elbowLWristL: return .leftWrist
        case .neckHipR: return .rightHip
        case .neckHipL: return .leftHip
        case .hipRKneeR: return .rightKnee
        case .kneeRAnkleR: return .rightAnkle
        case .hipLKneeL: return .leftKnee
        case .kneeLAnkleL: return .leftAnkle
        }
    }
}
