//
//  CollectionViewCell.swift
//  PhotoPicker
//
//  Created by Matthias Pueski on 25.02.18.
//

import UIKit

class CollectionViewCell : UICollectionViewCell {
    
    @IBOutlet var image : UIImageView!;
    
    var fullImage : GalleryImage?;
    
    func displayContent(img : GalleryImage) {
        image.image = img.thumb;
        image.frame = CGRect(x : 0, y : 0, width : 128, height : 128);
    }
    
}

