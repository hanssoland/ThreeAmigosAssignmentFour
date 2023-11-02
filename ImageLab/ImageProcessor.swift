//
//  ImageProcessor.swift
//  ImageLab
//
//  Created by Bryce Shurts and Jaime Garza on 11/1/23.
//  Copyright © 2023 Eric Larson. All rights reserved.
//

import Foundation
import CoreImage

class ImageProcessor {
    //MARK: Temporary Method
    func simulatePPG() -> [Float] {
        // Simulate a PPG signal for testing purposes
        var simulatedPPG: [Float] = []
        for _ in 0..<60 {
            let randomValue = Float.random(in: 0.5...1.0) // Simulated PPG values between 0.5 and 1.0
            simulatedPPG.append(randomValue)
        }
        return simulatedPPG
    }
    
    // MARK: Class Properties
    private var colorData: ImageData! = nil
    public var bpmData: BPMData! = nil
    
    struct ImageData {
        public var bufferPos: Int = 0
        public var red: [Float?] = [Float?](repeating: nil, count: 60)
        public var green: [Float?] = [Float?](repeating: nil, count: 60)
        public var blue: [Float?] = [Float?](repeating: nil, count: 60)
    }
    
    struct BPMData {
        public var bufferPos: Int = 0
        public var bpms: [Int] = [Int](repeating: 0, count: 30)
    }
    
    init() {
        self.colorData = ImageData()
        self.bpmData = BPMData()
    }

    func computeBPM(inputImage: CIImage) -> String {
        
        if inputImage.colorSpace {
            // case rgb = 1
            if inputImage.colorSpace.model == 1 {
                
                // If we have a newly filled buffer
                if self.colorData.bufferPos >= 60 {
                    self.colorData.bufferPos = 0
                    
                    //Compute the BPM
                    let bpm: Int = 0
                    let numPeaks: Int = 0
                    let avgColor: [Float?] =  [Float?](repeating: nil, count: 60)
                    
                    // Find the best colors for the PPG process and average them for each entry (33.3ms worth of data)
                    for index in 0...59 {
                        // value range: [0, 1.3333]
                        avgColor[index] = (self.colorData.red[index] * 1 + self.colorData.green * 2 + self.colorData.blue * 1)/3
                    }
                    
                    // Find any peaks in a 2 second range
                    for index in 1...58 {
                        // Check if we have a local peak
                        if avgColor[index] > avgColor[index - 1] + 0.0 && avgColor[index] > avgColor[index + 1] + 0.0 {
                            // Check if the local peak is a potential global peak
                            if avgColor[index] > 0.5 {
                                numPeaks++
                            }
                        }
                    }
                    
                    // Multiply the number of peaks by 30 to approximate the user's heart's BPM
                    bpm = numPeaks * 30
                    
                    if self.bpmData.bufferPos >= 30 {
                        self.bpmData.bufferPos = 0
                    }
                    self.bpmData.bpms[self.bpmData.bufferPos] = bpm
                    self.bpmData.bufferPos += 1
                }
                
                self.colorData.red[bufferPos] = inputImage.colorSpace?.colorTable[0]
                self.colorData.green[bufferPos] = inputImage.colorSpace?.colorTable[1]
                self.colorData.blue[bufferPos] = inputImage.colorSpace?.colorTable[2]
                self.colorData.bufferPos += 1
            }
            else {
               print("Colorspace's model is not in RGB mode")
            }
        }
        else {
            print("Color space does not exist for CIImage")
        }
        inputImage.colorSpace?.colorTable
        inputImage.colorSpace?.model

        // Update the PPG graph with the simulated data
        // Assuming you have access to the PPGGraphView instance here, call the update function
        // e.g., self.ppgGraphView.update(with: simulatedPPG)

        // For actual PPG signal extraction, replace the simulated data with your PPG extraction logic.

        // Compute the BPM and return it as a string
        return String(bpm)
    }
}

