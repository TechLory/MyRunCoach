//
//  CameraPreview.swift
//  PostureClassifier2
//
//  Created by Lorenzo Gatta on 23/03/25.
//

import Foundation
import SwiftUI
import AVFoundation



final class CameraPreview: UIView {
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}




struct CameraRepresentable: UIViewRepresentable {
    
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> CameraPreview {
        // Sol 1
        CameraPreview()
        // Sol 2
        //let view = CameraPreview()
        //view.previewLayer.session = session
        //view.previewLayer.videoGravity = .resizeAspectFill
        //return view
        
        
        
    }
    
    func updateUIView(_ uiView: CameraPreview, context: Context) {
        uiView.previewLayer.session = session
    }
    
    
}
