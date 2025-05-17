//
//  PostureClassifierModel.swift
//  PostureClassifier2
//
//  Created by Lorenzo Gatta on 23/03/25.
//

import CoreML

// Attention: use PostureClassifierModel Version 5.
@MainActor
class PostureClassifierModel: ObservableObject {
    
    private let inputModel: NSNumber = 60 // FPS * ACTION DURATION (OF THE MODEL)
    
    nonisolated private let model: PostureClassifierVersion5 = {
        return try! PostureClassifierVersion5(configuration: MLModelConfiguration())
    }()
    
    func predict(poses: [[[Float]]], completion: @escaping ([String: Double]?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let input = self.prepareInput(poses: poses) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            do {
                let output = try self.model.prediction(input: input)
                DispatchQueue.main.async {
                    completion(output.labelProbabilities)
                }
            } catch {
                print("Error in predict")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    
    
    /*
     This function takes a multi-array (poses) and builds a
     MLMultiArray in a form accepted as input by the ML model, and returns it.
     */
    nonisolated private func prepareInput(poses: [[[Float]]]) -> PostureClassifierVersion5Input? {
        do {

            let array = try MLMultiArray(shape: [inputModel, 3, 18], dataType: .float32)
            
            for (fIdx, frame) in poses.enumerated() {
                for (jIdx, joint) in frame.enumerated() {
                    for (cIdx, value) in joint.enumerated() {
                        let index = [fIdx, cIdx, jIdx] as [NSNumber]
                        array[index] = NSNumber(value: value)
                    }
                }
            }
            
            return PostureClassifierVersion5Input(poses: array)
        } catch {
            print("Error in prepareInput")
            return nil
        }
    }
}
