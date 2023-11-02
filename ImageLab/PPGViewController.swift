//
//  PPGViewController.swift
//  ImageLab
//
//  Created by Bryce Shurts and Jaime Garza on 11/1/23.
//  Copyright © 2023 Eric Larson. All rights reserved.
//

import UIKit
import MetalKit
import AVFoundation
import CoreImage

class PPGViewController: UIViewController {
    
    // MARK: Class Properties
    var cameraHandler: VisionAnalgesic! = nil
    var processor: ImageProcessor! = nil
    
    // MARK: View Outlets
    @IBOutlet weak var cameraView: MTKView!
    @IBOutlet weak var bpmText: UILabel!
    @IBOutlet weak var ppgGraphView: PPGGraphView! // Add a UIView for the PPG graph
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.processor = ImageProcessor()
        
        self.cameraHandler = VisionAnalgesic(view: self.cameraView)
        self.cameraHandler.setCameraPosition(position: AVCaptureDevice.Position.back)
        self.cameraHandler.setProcessingBlock(newProcessBlock: self.processImage)
        
        if !self.cameraHandler.isRunning {
            _ = self.cameraHandler.turnOnFlashwithLevel(0.5)
            self.cameraHandler.setFPS(desiredFrameRate: 30.0)
            self.cameraHandler.start()
        }
    }
    
    func processImage(input: CIImage) -> CIImage {
        
        // Compute the BPM and update the view
        bpmText.text = self.processor.computeBPM(inputImage: input)
        
        // Update the PPG graph with the simulated data
        self.ppgGraphView.update(with: self.processor.bpmData.bpms)

        return input
    }

class PPGGraphView: UIView {
    
    //MARK: Class Properties
    var ppgData: [Float] = []

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.clear(rect)
        context.setLineWidth(2.0)
        context.setStrokeColor(UIColor.blue.cgColor)

        for (index, value) in ppgData.enumerated() {
            let x = CGFloat(index) * (rect.width / CGFloat(ppgData.count - 1))
            let y = rect.height - (CGFloat(value) * rect.height)
            if index == 0 {
                context.move(to: CGPoint(x: x, y: y))
            } else {
                context.addLine(to: CGPoint(x: x, y: y))
            }
        }
        context.strokePath()
    }

    func update(with ppgSignal: [Int]) {
        ppgData = ppgSignal
        setNeedsDisplay() // Trigger a redraw
    }
}
