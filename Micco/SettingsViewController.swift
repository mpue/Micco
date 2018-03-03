//
//  SettingsViewController.swift
//  Micco
//
//  Created by Matthias Pueski on 28.02.18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit


class SettingsViewController : UIViewController,UIPickerViewDelegate, UIPickerViewDataSource {

    
    
    @IBOutlet var slider: UISlider?;
    @IBOutlet var hue: HuePicker?;
    @IBOutlet var color: ColorPicker?;
    @IBOutlet var colorWell : ColorWell?;
    @IBOutlet var filterPicker : UIPickerView?;
    
    var imageSpacing : Int = 0;
    var backgroundColor : UIColor = UIColor.gray;
    
    var filters : [String] = ImageFilters.getFilters();
    
    override func viewDidLoad() {
        slider?.value = Float(MiccoSettings.instance.imageSpacing);
        
        let controller = ColorPickerController(svPickerView:color!, huePickerView:hue!, colorWell:colorWell!);
        controller.color = MiccoSettings.instance.backgroundColor;
        
        controller.onColorChange = {(color, finished) in
            if finished {
                self.backgroundColor = color // reset background color to white
                MiccoSettings.instance.backgroundColor = self.backgroundColor;
            } else {
                self.backgroundColor = color // set background color to current selected color (finger is still down)
                 MiccoSettings.instance.backgroundColor = self.backgroundColor;
            }
        }
        
        filterPicker?.dataSource = self;
        filterPicker?.delegate = self;
        
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filters.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return filters[row];
    }
    
    
    @IBAction func setImageSpacing(sender: UISlider) {
        imageSpacing = Int(sender.value);
        MiccoSettings.instance.imageSpacing = imageSpacing;
    }
    
    
    
}
