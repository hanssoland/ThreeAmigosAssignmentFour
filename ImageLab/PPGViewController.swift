//
//  PPGViewController.swift
//  ImageLab
//
//  Created by Bryce Shurts on 11/1/23.
//  Copyright © 2023 Eric Larson. All rights reserved.
//

import UIKit
import MetalKit
import AVFoundation

class PPGViewController: UIViewController {
    
    //MARK: Class Properties
    var cameraHandler: VisionAnalgesic! = nil
    var processor: imageProcessor! = nil
    
    //MARK: View Outlets
    @IBOutlet weak var cameraView: MTKView!
    @IBOutlet weak var bpmText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.processor = imageProcessor()
        
        self.cameraHandler = VisionAnalgesic(view: self.cameraView)
        self.cameraHandler.setCameraPosition(position: AVCaptureDevice.Position.back)
        self.cameraHandler.setProcessingBlock(newProcessBlock: self.processImage)
        
        if !self.cameraHandler.isRunning {
            _ = self.cameraHandler.turnOnFlashwithLevel(0.5)
            self.cameraHandler.setFPS(desiredFrameRate: 60.0)
            self.cameraHandler.start()
        }
    }
    
    func processImage(input: CIImage) -> CIImage {
        
        // Draw the graph here
        
        // Compute the BPM and update the view
        bpmText.text = self.processor.computeBPM(inputImage: input)

        return input
    }
}
