//
//  ViewController.swift
//  Micco
//
//  Created by Matthias Pueski on 25.02.18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var cameraButton: UIBarButtonItem?
    @IBOutlet var trashButton: UIBarButtonItem?
    @IBOutlet var copyButton: UIBarButtonItem?
    @IBOutlet var shareButton: UIBarButtonItem?
    @IBOutlet var exportButton: UIBarButtonItem?
    @IBOutlet var overlayView : UIView?
    @IBOutlet var imageGrid: UICollectionView?
    @IBOutlet var toggleSelectButton: UIBarButtonItem?
    
    var selectMode = false;
    
    var currentSection = Int(0);
    
    var gallery = [[GalleryImage]]();
    
    var imagePicker = UIImagePickerController();
    
    var currentCell : CollectionViewCell = CollectionViewCell();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        imagePicker.modalPresentationStyle = .currentContext
        imagePicker.delegate = self
        
        // Remove the camera button if the camera is not currently available.
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            toolbarItems = self.toolbarItems?.filter { $0 != cameraButton }
        }
        
        self.imageGrid?.isUserInteractionEnabled = true;
        self.imageGrid?.allowsMultipleSelection = true;
        self.imageGrid?.allowsSelection = true;
        
        
        /*
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.imageTapped))
        lpgr.cancelsTouchesInView = false
        self.imageGrid?.addGestureRecognizer(lpgr);
        
        */
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        tapGestureRecognizer.cancelsTouchesInView = true
        self.imageGrid?.addGestureRecognizer(tapGestureRecognizer);
        
        
        let defaultGallery = [GalleryImage]();
        
        gallery.append(defaultGallery);
        
        loadThumbnails();
        
        self.trashButton?.isEnabled = false;
        self.copyButton?.isEnabled = false;
        self.shareButton?.isEnabled = false;
        self.exportButton?.isEnabled = false;
        

    }
    
    func loadThumbnails() {
        _ = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            
            for var url in fileURLs {
                
                if (!url.path.contains("thumb")) {
                    let image = UIImage(contentsOfFile: url.path);
                    let thumbPath = url.path.replacingOccurrences(of: ".jpg", with: "_thumb.jpg");
                    let thumb = UIImage(contentsOfFile: thumbPath)
                    let galleryImage = GalleryImage();
                    galleryImage.thumb = thumb;
                    galleryImage.image = image;
                    galleryImage.imagePath = url.path;
                    galleryImage.thumbPath = thumbPath;
                    gallery[currentSection].append(galleryImage);
                    
                }
                
            }
            
        } catch {
            print("Error while enumerating files");
        }
    }
    
    @objc func imageTapped(gesture: UITapGestureRecognizer)
    {
        
        if gesture.state != .ended {
            return
        }
        let p = gesture.location(in: self.imageGrid)
        
        if let indexPath = self.imageGrid?.indexPathForItem(at: p) {
            // get the cell at indexPath (the one you long pressed)
            let cell = self.imageGrid?.cellForItem(at: indexPath)
            self.currentCell = cell as! CollectionViewCell
            self.currentCell.imageIndex =  indexPath.first;
            
            if (selectMode) {
                if (self.currentCell.isSelected) {
                    self.imageGrid?.deselectItem(at: indexPath, animated: true);
                }
                else {
                    self.imageGrid?.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
                }
                

                self.checkToolbarState();
            }
            else {
                self.performSegue(withIdentifier: "showImage", sender: self.currentCell);
            }

            
        } else {
            print("couldn't find index path")
        }

    }
    
    @objc func handleLongPress(gesture : UILongPressGestureRecognizer!) {
        if gesture.state != .ended {
            return
        }
        let p = gesture.location(in: self.imageGrid)
        
        if let indexPath = self.imageGrid?.indexPathForItem(at: p) {
            // get the cell at indexPath (the one you long pressed)
            let cell = self.imageGrid?.cellForItem(at: indexPath)
            self.imageGrid?.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
 
        } else {
            print("couldn't find index path")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.destination is ImageViewController) {
            let controller = segue.destination as? ImageViewController;
            // self.navigationController?.pushViewController(self, animated: true)
            let cell = sender as! CollectionViewCell;
            controller?.gallery = self.gallery[currentSection];
            controller?.photo = (cell.fullImage?.image)!;
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    @IBAction func showCamera(_ sender: UIBarButtonItem) {
        showImagePickerForCamera(cameraButton!);
    }
    
    
    @IBAction func shareImages(_ sender: UIBarButtonItem) {
        let indexPaths = self.imageGrid?.indexPathsForSelectedItems;
        
        var objectsToShare : [URL] = [];
        
        for path in indexPaths! {
            
            var image = gallery[currentSection][path.item];
            var fileUrl = NSURL(fileURLWithPath: image.imagePath!);
            objectsToShare.append(fileUrl as URL);
            
        }
        
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func copyToGallery(_ sender: UIBarButtonItem) {
    
        let indexPaths = self.imageGrid?.indexPathsForSelectedItems;
        
        for path in indexPaths! {
            
            var image = gallery[currentSection][path.item];
            UIImageWriteToSavedPhotosAlbum(image.image!,self,#selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
        }
    }
    
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    @IBAction func exportThumbs(_ sender: UIBarButtonItem) {
        let indexPaths = self.imageGrid?.indexPathsForSelectedItems;
        let numImages = Double((indexPaths?.count)!);
        
        let columns = Int(sqrt(numImages));
        let rows = Int(Int(numImages) / columns);
 
        // The computed image needs top be larger because of the image padding in between
        let bordersize = CGFloat(MiccoSettings.instance.imageSpacing);
        
        // actually this is n times the image width/height + one additional border
        let borderVertical = CGFloat(CGFloat(rows - 1) * bordersize) - bordersize;
        let borderHorizontal = CGFloat(CGFloat(columns - 1) * bordersize) - bordersize;
        
        let size = CGSize(width: 256 * CGFloat(columns) + borderHorizontal, height: 256 * CGFloat(rows) + borderVertical)
        
        UIGraphicsBeginImageContext(size)

        let context = UIGraphicsGetCurrentContext();
        context?.setFillColor(MiccoSettings.instance.backgroundColor.cgColor)
        context!.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        var col = 0;
        var row = 0;
        
        for path in indexPaths! {
            
            let image = gallery[currentSection][path.item];

            let areaSize = CGRect( x : CGFloat(col * 256) + bordersize, y : CGFloat(row * 256) + bordersize,width: CGFloat(256) - bordersize, height: CGFloat(256) - bordersize);
            
            image.thumb?.draw(in: areaSize, blendMode: CGBlendMode.normal, alpha: CGFloat(1));
            
            if (col < columns - 1) {
                col = col + 1;
            }
            else {
                col = 0;
                row = row + 1;
            }
            
        }
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        UIImageWriteToSavedPhotosAlbum(newImage,self,#selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func deleteSelected(_ sender: UIBarButtonItem) {

        let indexPaths = self.imageGrid?.indexPathsForSelectedItems;
        
        for path in indexPaths! {
            
            var image = gallery[currentSection][path.first!];
            
            removeImage(filePath: image.imagePath!);
            removeImage(filePath: image.thumbPath!);
            self.gallery[currentSection].remove(at: path.first!);
        }
        self.imageGrid?.performBatchUpdates({
             self.imageGrid?.deleteItems(at: indexPaths!)
        }) { (finished) in
            // self.imageGrid?.reloadItems(at: (self.imageGrid?.indexPathsForVisibleItems)!)
        }
    }
    
    func removeImage(filePath: String) {
        let fileManager = FileManager.default
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        guard let dirPath = paths.first else {
            return
        }

        do {
            try fileManager.removeItem(atPath: filePath)
        } catch let error as NSError {
            print(error.debugDescription)
        }
        
    }
    
    @IBAction func toggleSelect(_ sender: UIBarButtonItem) {
        
        selectMode = !selectMode;
        
        if (selectMode) {
            sender.title = "Cancel";
        }
        else {
            sender.title = "Select";
        }
        
    }
    
    @IBAction func backToMain(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: { [weak self] in
            guard let `self` = self else {
                return
            }
        })
        self.imageGrid?.reloadSections(IndexSet(integer : 0));
    }
    
    @IBAction func showImagePickerForCamera(_ sender: UIBarButtonItem) {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        if authStatus == AVAuthorizationStatus.denied {
            // Denied access to camera, alert the user.
            // The user has previously denied access. Remind the user that we need camera access to be useful.
            let alert = UIAlertController(title: "Unable to access the Camera",
                                          message: "To enable access, go to Settings > Privacy > Camera and turn on Camera access for this app.",
                                          preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okAction)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { _ in
                // Take the user to Settings app to possibly change permission.
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else { return }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        // Finished opening URL
                    })
                }
            })
            alert.addAction(settingsAction)
            
            present(alert, animated: true, completion: nil)
        }
        else if (authStatus == AVAuthorizationStatus.notDetermined) {
            // The user has not yet been presented with the option to grant access to the camera hardware.
            // Ask for permission.
            //
            // (Note: you can test for this case by deleting the app on the device, if already installed).
            // (Note: we need a usage description in our Info.plist to request access.
            //
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                if granted {
                    DispatchQueue.main.async {
                        self.showImagePicker(sourceType: UIImagePickerControllerSourceType.camera, button: sender)
                    }
                }
            })
        } else {
            // Allowed access to camera, go ahead and present the UIImagePickerController.
            showImagePicker(sourceType: UIImagePickerControllerSourceType.camera, button: sender)
        }
    }
    
    @IBAction func showImagePickerForPhotoPicker(_ sender: UIBarButtonItem) {
        showImagePicker(sourceType: UIImagePickerControllerSourceType.photoLibrary, button: sender)
    }
    
    fileprivate func showImagePicker(sourceType: UIImagePickerControllerSourceType, button: UIBarButtonItem) {
        imagePicker.sourceType = sourceType
        imagePicker.modalPresentationStyle =
            (sourceType == UIImagePickerControllerSourceType.camera) ?
                UIModalPresentationStyle.fullScreen : UIModalPresentationStyle.popover
 
    
        let presentationController = imagePicker.popoverPresentationController
        presentationController?.barButtonItem = button     // Display popover from the UIBarButtonItem as an anchor.
        presentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
        
        if sourceType == UIImagePickerControllerSourceType.camera {
            // The user wants to use the camera interface. Set up our custom overlay view for the camera.
            imagePicker.showsCameraControls = false

            overlayView?.frame = (imagePicker.cameraOverlayView?.frame)!
            imagePicker.cameraOverlayView = overlayView
        }
 
        
        present(imagePicker, animated: true, completion: {
            // Done presenting.
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func takePhoto(_ sender: UIBarButtonItem) {
        imagePicker.takePicture();

    }

    func sectionDirectoryExists(name : String) -> Bool {
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: AnyObject = paths[0] as AnyObject
        let dataPath = documentsDirectory.appendingPathComponent(name)!
        
        return FileManager.default.fileExists(atPath: dataPath.absoluteString)
        
    }
    
    func createDirectoryForSection(name : String) {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: AnyObject = paths[0] as AnyObject
        let dataPath = documentsDirectory.appendingPathComponent(name)!
        
        do {
            try FileManager.default.createDirectory(atPath: dataPath.absoluteString, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription);
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage]
        let galleryImage = GalleryImage();
        galleryImage.image = image as? UIImage;
        gallery[currentSection].append(galleryImage)
       
        
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        
        

        let imgPath = URL(fileURLWithPath: documentDirectoryPath.appendingPathComponent("\(gallery[currentSection].count).jpg"))
        let thbImgPath = URL(fileURLWithPath: documentDirectoryPath.appendingPathComponent("\(gallery[currentSection].count)_thumb.jpg"))
        
        do {
            
            let imageData = UIImagePNGRepresentation(rotateImage(image : image as! UIImage))!
            
            let options = [
                kCGImageSourceCreateThumbnailWithTransform: false,
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceThumbnailMaxPixelSize: 256] as CFDictionary
            let source = CGImageSourceCreateWithData(imageData as CFData, nil)!
            let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options)!
            let thumbnail = UIImage(cgImage: imageReference)
            
            galleryImage.thumb = thumbnail;
            galleryImage.thumbPath = thbImgPath.absoluteString;
            galleryImage.imagePath = imgPath.absoluteString;
            
            try UIImageJPEGRepresentation(thumbnail as! UIImage, 1.0)?.write(to: thbImgPath, options: .atomic)
            try UIImageJPEGRepresentation(image as! UIImage, 1.0)?.write(to: imgPath, options: .atomic)
        }
        catch let error{
            print(error.localizedDescription)
        }
    }
    
    func rotateImage(image:UIImage) -> UIImage
    {
        var rotatedImage = UIImage()
        switch UIDevice.current.orientation
        {
        case .portrait:
            rotatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .right)
            
        case .portraitUpsideDown:
            rotatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .left)
            
        case .landscapeLeft:
            rotatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .up)
            
        default:
            rotatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .down)
        }
        
        return rotatedImage
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return `self`.gallery[section].count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        
        if (indexPath.row < `self`.gallery[currentSection].count) {
            cell.fullImage = self.gallery[currentSection][indexPath.row]
            cell.displayContent( img : self.gallery[currentSection][indexPath.row]);
        }
        
        return cell;
    }
    
    func checkToolbarState() {
        let enabled = (imageGrid?.indexPathsForSelectedItems?.count)! > 0;
        trashButton?.isEnabled = enabled
        copyButton?.isEnabled = enabled
        shareButton?.isEnabled = enabled
        exportButton?.isEnabled = enabled
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    

}

