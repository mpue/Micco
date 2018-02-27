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
    @IBOutlet var overlayView : UIView?
    @IBOutlet var imageGrid: UICollectionView?
    
    var gallery = [GalleryImage]();
    
    var imagePicker = UIImagePickerController();
    
    var currentCell : CollectionViewCell = CollectionViewCell();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        imagePicker.modalPresentationStyle = .currentContext
        imagePicker.delegate = self
        
        imageGrid?.dataSource = self;
        imageGrid?.delegate = self;
        
        // Remove the camera button if the camera is not currently available.
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            toolbarItems = self.toolbarItems?.filter { $0 != cameraButton }
        }
        
        loadThumbnails();

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
                    gallery.append(galleryImage);
                    
                }
                
            }
            
        } catch {
            print("Error while enumerating files");
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.currentCell = tapGestureRecognizer.view as! CollectionViewCell
        self.performSegue(withIdentifier: "showImage", sender: self.currentCell);
        // Your action
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as? ImageViewController;
        // self.navigationController?.pushViewController(self, animated: true)
        let cell = sender as! CollectionViewCell;
        controller?.photo = (cell.fullImage?.image)!;
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    @IBAction func showCamera(_ sender: UIBarButtonItem) {
        showImagePickerForCamera(cameraButton!);
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage]
        let galleryImage = GalleryImage();
        galleryImage.image = image as? UIImage;
        gallery.append(galleryImage)
       
        
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString

        let imgPath = URL(fileURLWithPath: documentDirectoryPath.appendingPathComponent("\(gallery.count).jpg"))
        let thbImgPath = URL(fileURLWithPath: documentDirectoryPath.appendingPathComponent("\(gallery.count)_thumb.jpg"))
        
        do {
            let imageData = UIImagePNGRepresentation(image as! UIImage)!
            let options = [
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceThumbnailMaxPixelSize: 256] as CFDictionary
            let source = CGImageSourceCreateWithData(imageData as CFData, nil)!
            let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options)!
            let thumbnail = UIImage(cgImage: imageReference)
            
            galleryImage.thumb = thumbnail;
            
            try UIImageJPEGRepresentation(thumbnail as! UIImage, 1.0)?.write(to: thbImgPath, options: .atomic)
            try UIImageJPEGRepresentation(image as! UIImage, 1.0)?.write(to: imgPath, options: .atomic)
        }
        catch let error{
            print(error.localizedDescription)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return `self`.gallery.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        
        if (cell.gestureRecognizers?.count == nil) {
            var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            cell.addGestureRecognizer(tapGestureRecognizer);
        }
        
        if (indexPath.row < `self`.gallery.count) {
            cell.fullImage = self.gallery[indexPath.row]
            cell.displayContent( img : self.gallery[indexPath.row]);
        }
        
        return cell;
    }
    

}

