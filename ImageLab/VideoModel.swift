//
//  VideoModel.swift
//  ImageLab
//
//  Created by Hans Soland on 10/31/23.
//  Copyright © 2023 Eric Larson. All rights reserved.
//

import UIKit
import CoreImage
import MetalKit

class VideoModel: NSObject {
    
    weak var cameraView: MTKView? // view display
    
    // MARK: Class Properties
    
    // utilizes VisionAnalgesic and processes viedo frames
    private lazy var videoManager: VisionAnalgesic! = {
        let tmpManager = VisionAnalgesic(view: cameraView!)
        tmpManager.setCameraPosition(position: .front) // default set to front camera
        return tmpManager
    }()
    
    // identifies the faces in vid frames
    private lazy var detector: CIDetector! = {
        let optsDetector = [
            CIDetectorAccuracy: CIDetectorAccuracyHigh
        ] as [String : Any]
        
        return CIDetector(ofType: CIDetectorTypeFace, context: self.videoManager.getCIContext(), options: optsDetector)
    }()
    
    // initialization
    init(view: MTKView) {
        super.init()
        cameraView = view
        self.videoManager.setCameraPosition(position: .front)
        self.videoManager.setProcessingBlock(newProcessBlock: self.processImage)
        // ensures videoManager is running
        if !videoManager.isRunning {
            videoManager.start()
        }
    }
    
    // fetches the faes from the image
    private func getFaces(img: CIImage) -> [CIFaceFeature] {
        let optsFace = [CIDetectorImageOrientation: self.videoManager.ciOrientation]
        return self.detector.features(in: img, options: optsFace) as! [CIFaceFeature]
    }
    
    // MARK: Process image output
    
    // process and highlights faces
    private func processImage(inputImage: CIImage) -> CIImage {
        let faces = getFaces(img: inputImage)
        if faces.count == 0 { return inputImage }
        return highlightFacesAndFeatures(inputImage: inputImage, features: faces)
    }
    
    // feature positioning
    private func transformPosition(_ position: CGPoint, imageSize: CGSize) -> CGPoint {
        return CGPoint(x: position.x, y: imageSize.height - position.y)
    }
    
    // function for highlighting facial features
    private func highlightFacesAndFeatures(inputImage: CIImage, features: [CIFaceFeature]) -> CIImage {
        let faceColor = UIColor.red.cgColor
        let featureColor = UIColor.green.cgColor

        let size = inputImage.extent.size
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        
        UIImage(ciImage: inputImage).draw(in: CGRect(origin: .zero, size: size))
        
        // loops through each faces and highlights them along with features
        for face in features {
            context.setStrokeColor(faceColor)
            context.setLineWidth(3.0)

            let transformedBounds = CGRect(x: face.bounds.origin.x,
                                           y: size.height - face.bounds.origin.y - face.bounds.height,
                                           width: face.bounds.width,
                                           height: face.bounds.height)
            context.stroke(transformedBounds)
            
            let transformedLeftEye = transformPosition(face.leftEyePosition, imageSize: size)
            let transformedRightEye = transformPosition(face.rightEyePosition, imageSize: size)
            let transformedMouth = transformPosition(face.mouthPosition, imageSize: size)

            // calls drawCircle for mouth and eyes
            if face.hasLeftEyePosition {
                drawCircle(context: context, position: transformedLeftEye, color: featureColor, radius: 10)
            }
            if face.hasRightEyePosition {
                drawCircle(context: context, position: transformedRightEye, color: featureColor, radius: 10)
            }
            if face.hasMouthPosition {
                drawCircle(context: context, position: transformedMouth, color: featureColor, radius: 15)
            }
        }

        let highlightedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return CIImage(image: highlightedImage!)!
    }

    // drawCircle function for facial features
    private func drawCircle(context: CGContext, position: CGPoint, color: CGColor, radius: CGFloat) {
        context.setStrokeColor(color)
        context.setLineWidth(2.0)
        let rect = CGRect(x: position.x - radius, y: position.y - radius, width: radius * 2, height: radius * 2)
        context.strokeEllipse(in: rect)
    }
}

