//
//  PostureClassifierModel.swift
//  PostureClassifier2
//
//  Created by Lorenzo Gatta on 23/03/25.
//

import CoreML


@MainActor
class PostureClassifierModel: ObservableObject {
    
    private let model: PostureClassifier1
    
    
    // This function sets up the custom ML model.
    init() {
        self.model = try! PostureClassifier1(configuration: MLModelConfiguration())
    }
    
    
    // This function takes a multi-array (poses) and returns the prediction made by the model, as a map class:probability.
    func predict(poses: [[[Float]]]) -> [String: Double]? {
        guard let input = prepareInput(poses: poses) else { return nil }
        
        do {
            let output = try model.prediction(input: input)
            return output.labelProbabilities
        } catch {
            print("Error in predict")
            return nil
        }
    }
    
    
    /*
     This function takes a multi-array (poses) and builds a
     MLMultiArray in a form accepted as input by the ML model, and returns it.
     */
    private func prepareInput(poses: [[[Float]]]) -> PostureClassifier1Input? {
        do {
            let array = try MLMultiArray(shape: [60, 3, 18], dataType: .float32)
            
            for (fIdx, frame) in poses.enumerated() {
                for (jIdx, joint) in frame.enumerated() {
                    for (cIdx, value) in joint.enumerated() {
                        let index = [fIdx, cIdx, jIdx] as [NSNumber]
                        array[index] = NSNumber(value: value)
                    }
                }
            }
            
            return PostureClassifier1Input(poses: array)
        } catch {
            print("Error in prepareInput")
            return nil
        }
    }
}
