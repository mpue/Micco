//
//  ColorPicker.swift
//  Micco
//
//  Created by Matthias Pueski on 01.03.18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit
@IBDesignable
class SimpleColorPicker : UIControl {
    
    override init(frame: CGRect) {
        super.init(frame : frame);
         isOpaque = true;
        self.backgroundColor = UIColor.green;
        autoresizingMask = [.flexibleWidth, .flexibleHeight]

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder : aDecoder)
         isOpaque = true;
        self.backgroundColor = UIColor.green;
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    
    @IBInspectable var startColor: UIColor = .red
    @IBInspectable var endColor: UIColor = .green
    
    override func draw(_ rect: CGRect) {
        
        
        let context = UIGraphicsGetCurrentContext()!
        let colors = [startColor.cgColor, endColor.cgColor]
        
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        
        let colorLocations: [CGFloat] = [0.0, 1.0]
        
        
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)!
        
        // 6
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: bounds.height)
        context.drawLinearGradient(gradient,
                                   start: startPoint,
                                   end: endPoint,
                                   options: [])
    }

}
