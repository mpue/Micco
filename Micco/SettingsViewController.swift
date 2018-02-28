//
//  SettingsViewController.swift
//  Micco
//
//  Created by Matthias Pueski on 28.02.18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit

class SettingsViewController : UIViewController {
    
    var imageSpacing : Int = 0;
    
    @IBAction func setImageSpacing(sender: UISlider) {
        imageSpacing = Int(sender.value);
        MiccoSettings.instance.imageSpacing = imageSpacing;
    }
    
    
    
}
