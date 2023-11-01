//
//  ImageProcessor.swift
//  ImageLab
//
//  Created by Bryce Shurts on 11/1/23.
//  Copyright © 2023 Eric Larson. All rights reserved.
//

import Foundation
import CoreImage

class imageProcessor {
    
    //MARK: Class Properties
    var data: imageData! = nil
    
    struct imageData {
        
        public var bufferPos: Int = 0
        public var red: [Float?] = [Float?](repeating: nil, count: 60)
        public var green: [Float?] = [Float?](repeating: nil, count: 60)
        public var blue: [Float?] = [Float?](repeating: nil, count: 60)
    }
    
    init() {
        self.data = imageData()
    }

    func computeBPM(inputImage: CIImage) -> String {
        
        // Grab RGB color info
            
        return "Test"
    }
}
