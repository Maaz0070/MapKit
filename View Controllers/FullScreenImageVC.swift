//
//  FullScreenImageVC.swift
//  RealEstate
//
//  Created by CodeGradients on 18/08/2020.
//  Copyright Â© 2020 Code Gradients. All rights reserved.
//

import UIKit
import ImageScrollView
import Photos

class FullScreenImageVC: UIViewController {
    
    @IBOutlet weak var image_view: ImageScrollView! //outlet to the scrolling image view
    
    var img_link: UIImage! //the image itself
    
    /*
        Sets up the image view, laying out and displaying the image if needed and adding a long press gesture recognizer which calls didTappedImageView
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        image_view.setup()
        
        if let img = img_link {
            self.image_view.display(image: img)
            self.view.layoutIfNeeded()
            
            self.image_view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didTappedImageView(_:))))
        }
    }
    
    /*
       Closes the FullScreenImageView being presented (this instance)
     */
    @IBAction func didPressedCloseButton(_ sender: BorderedButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     When the image is long-press (not simply tapped), give the user an alert offereing them to save the image
     
     @permissions: Needs access to the user's photo library, asks for permission if not determined
     */
    @objc func didTappedImageView(_ sender: UILongPressGestureRecognizer) {
        if let img = img_link {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Save to Camera Roll", style: .default, handler: { (ac) in
                let status = PHPhotoLibrary.authorizationStatus()
                switch status {
                case .authorized:
                    self.saveImageToCameraRoll(img: img)
                    break
                case .notDetermined:
                    PHPhotoLibrary.requestAuthorization { (st) in
                        switch st {
                        case .authorized:
                            self.saveImageToCameraRoll(img: img)
                            break
                        case .notDetermined, .restricted, .denied:
                            AlertBuilder().buildMessage(vc: self, message: "Access is required to save Image")
                            break
                        default:
                            break
                        }
                    }
                    break
                case .restricted, .denied:
                    AlertBuilder().buildMessage(vc: self, message: "Access is required to save Image")
                    break
                default:
                    break
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.popoverPresentationController?.sourceView = image_view
            self.present(alert, animated: true, completion: nil)
        } else {
            AlertBuilder().buildMessage(vc: self, message: "Image not Found!")
        }
    }
    
    /*
     Save the image to camera roll, using a custom photo album in the Photo Library
     */
    func saveImageToCameraRoll(img: UIImage) {
        let cp = CustomPhotoAlbum()
        cp.saveImage(image: img) { (res) in
            DispatchQueue.main.async {
                if res {
                    AlertBuilder().buildMessage(vc: self, message: "Image Saved")
                } else {
                    AlertBuilder().buildMessage(vc: self, message: "Failed to Save Image")
                }
            }
        }
    }
}
