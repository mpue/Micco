//
//  ImageFilters.swift
//  Micco
//
//  Created by Matthias Pueski on 01.03.18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit

class ImageFilters {
    
    static func simpleGaussianBlur(inputImage: UIImage) -> UIImage {
        // convert UIImage to CIImage
        let inputCIImage = CIImage(image: inputImage)!
        
        // Create Blur CIFilter, and set the input image
        let blurFilter = CIFilter(name: "CIGaussianBlur")!
        blurFilter.setValue(inputCIImage, forKey: kCIInputImageKey)
        blurFilter.setValue(8, forKey: kCIInputRadiusKey)
        
        // Get the filtered output image and return it
        let outputImage = blurFilter.outputImage!
        return UIImage(ciImage: outputImage)
    }
    
    static func getFilters() -> [String]{
        return CIFilter.filterNames(inCategories: nil)
    }
    
}
