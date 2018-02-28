//
//  ImageViewController.swift
//  Micco
//
//  Created by Matthias Pueski on 25.02.18.
//  Copyright © 2018 Private. All rights reserved.
//

import Foundation
import UIKit

class ImageViewController : UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var image : UIImageView!;
    @IBOutlet weak var scrollView: UIScrollView!
    var gallery : [GalleryImage]?;
    var currentIndex : Int = 0;
    var photo:UIImage = UIImage();
    var orientation : UIDeviceOrientation = UIDevice.current.orientation;
    
    override func viewDidLoad() {
    
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        
        image.image = photo;
     
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(imageTapped))
        image.addGestureRecognizer(tapGestureRecognizer);
        image.isUserInteractionEnabled = true
        
        adjustImage()
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.getSwipeAction(_:)))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right;
        self.image.addGestureRecognizer(rightSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.getSwipeAction(_:)))
        leftSwipe.direction = UISwipeGestureRecognizerDirection.left;
        self.image.addGestureRecognizer(leftSwipe)
        
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        var text=""
        orientation = UIDevice.current.orientation;
        adjustImage();
    }
    
    @objc func getSwipeAction( _ recognizer : UISwipeGestureRecognizer){
        
        let count = (gallery?.count)!;
        let index = self.currentIndex;
        
        if recognizer.direction == .left{
            
            if index < count - 1 {
                currentIndex = currentIndex + 1;
                
                let newImage =  gallery![currentIndex].image;
                
                UIView.transition(with: self.image,
                                  duration:0.5,
                                  options: .transitionFlipFromRight,
                                  animations: { self.image.image = newImage },
                                  completion: nil)
                
            }
        } else  {
            if index > 0 {
                currentIndex = currentIndex - 1;
                
                let newImage =  gallery![currentIndex].image;
                
                UIView.transition(with: self.image,
                                  duration:0.5,
                                  options: .transitionFlipFromLeft,
                                  animations: { self.image.image = newImage },
                                  completion: nil)
            }
        }
        
        adjustImage();
    }
    
    func adjustImage() {
        image.contentMode = .scaleAspectFit
        /*
        let width = (image.image?.size.width)!;
        let height =  (image.image?.size.height)!;
        
        if width > height {
            if (orientation == .landscapeLeft || orientation == .landscapeRight) {
                image.contentMode = .scaleAspectFit
            }
            else if (orientation == .portrait || orientation == .portraitUpsideDown) {
                image.contentMode = .scaleAspectFill
            }
            
        } else {
            if (orientation == .landscapeLeft || orientation == .landscapeRight) {
                 image.contentMode = .scaleAspectFill
            }
            else if (orientation == .portrait || orientation == .portraitUpsideDown) {
                 image.contentMode = .scaleAspectFit
            }
           
            //width < height we fill it until width is taken up and clipped on top/bottom
        }
         */
    }
    
    @objc func imageTapped(sender: Any)
    {
        self.navigationController?.popViewController(animated: true);
        // Your action
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return image;
    }
    
}
