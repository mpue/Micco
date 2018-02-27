//
//  ImageViewController.swift
//  Micco
//
//  Created by Matthias Pueski on 25.02.18.
//  Copyright © 2018 Private. All rights reserved.
//

import Foundation
import UIKit

class ImageViewController : UIViewController {
    
    @IBOutlet var image : UIImageView!;

    var photo:UIImage = UIImage();

    
    override func viewDidLoad() {
        image.image = photo;
     
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(imageTapped))
        image.addGestureRecognizer(tapGestureRecognizer);
        image.isUserInteractionEnabled = true
        
        let width = photo.size.width;
        let height =  photo.size.height;
        
        if width > height {
            image.contentMode = .scaleAspectFit
            //since the width > height we may fit it and we'll have bands on top/bottom
        } else {
            image.contentMode = .scaleAspectFill
            //width < height we fill it until width is taken up and clipped on top/bottom
        }
    }
    
    @objc func imageTapped(sender: Any)
    {
        self.navigationController?.popViewController(animated: true);
        // Your action
    }
    
}
