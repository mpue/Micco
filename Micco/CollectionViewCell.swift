//
//  CollectionViewCell.swift
//  PhotoPicker
//
//  Created by Matthias Pueski on 25.02.18.
//

import UIKit

class CollectionViewCell : UICollectionViewCell {
    
    @IBOutlet var image : UIImageView!;
    @IBOutlet var cellCheckMarkImage: UIImageView!
    var imageIndex : Int?;
    
    var fullImage : GalleryImage?;
    
    func displayContent(img : GalleryImage) {
        image.image = img.thumb;
        image.frame = CGRect(x : 0, y : 0, width : 128, height : 128);
        self.isSelected = false;
    }
    
    override var isSelected: Bool{
        didSet{
            if self.isSelected
            {
                self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                self.contentView.backgroundColor = UIColor.blue
                self.cellCheckMarkImage.isHidden = false;
            }
            else
            {
                self.transform = CGAffineTransform.identity
                self.contentView.backgroundColor = UIColor.gray
                self.cellCheckMarkImage.isHidden = true;
            }
        }
    }

    
}

