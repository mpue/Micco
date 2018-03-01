//
//  SettingsViewController.swift
//  Micco
//
//  Created by Matthias Pueski on 28.02.18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit


class SettingsViewController : UIViewController {
    
    @IBOutlet var slider: UISlider?;
    @IBOutlet var hue: HuePicker?;
    @IBOutlet var color: ColorPicker?;
    @IBOutlet var colorWell : ColorWell?;
    
    var imageSpacing : Int = 0;
    
 
    
    override func viewDidLoad() {
        slider?.value = Float(MiccoSettings.instance.imageSpacing);
        
        let controller = ColorPickerController(svPickerView:color!, huePickerView:hue!, colorWell:colorWell!);
        controller.color = UIColor.red;
    }
    
    @IBAction func setImageSpacing(sender: UISlider) {
        imageSpacing = Int(sender.value);
        MiccoSettings.instance.imageSpacing = imageSpacing;
    }
    
    
    
}
