//
//  OmageViewController.swift
//  Omage
//
//  Created by Wenzheng Li on 10/30/15.
//  Copyright © 2015 Wenzheng Li. All rights reserved.
//

import UIKit

class OmageViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    
    @IBOutlet weak var imageViewContainer: UIView!
    
    @IBOutlet weak var photoButton: PhotoButton!
    
    @IBOutlet weak var cameraButton: CameraButton!
    
    // MARK - background image
    private var backgroundImageView: UIImageView?
    private var backgroundImage: UIImage? {
        get { return backgroundImageView?.image }
        set {
            if newValue != nil {
                if backgroundImageView != nil {
                    backgroundImageView!.removeFromSuperview()
                }
                backgroundImageView = UIImageView()
                
                backgroundImageView!.backgroundColor = UIColor.clearColor()
                backgroundImageView!.image = newValue
                imageViewContainer.addSubview(backgroundImageView!)
//                if handwrittingImageView != nil {
//                    imageViewContainer.bringSubviewToFront(handwrittingImageView!)
//                }
            }
        }
    }

    // MARK - handwritting image
    private var handwrittingImageView: UIImageView?
    private var handwrittingImage: UIImage? {
        get { return handwrittingImageView?.image }
        set {
            if newValue != nil {
                if handwrittingImageView != nil {
                    handwrittingImageView!.removeFromSuperview()
                }
                handwrittingImageView = UIImageView()
                
                handwrittingImageView!.backgroundColor = UIColor.clearColor()
                handwrittingImageView!.multipleTouchEnabled = true
                handwrittingImageView!.exclusiveTouch = true
                
                handwrittingImageView!.image = newValue
                imageViewContainer.addSubview(handwrittingImageView!)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.bringSubviewToFront(photoButton)
        self.view.bringSubviewToFront(cameraButton)
    }
    
    
    @IBAction func pickImage() {
        
        if UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum) {
            let picker = UIImagePickerController()
            picker.sourceType = .SavedPhotosAlbum
            picker.delegate = self
            picker.allowsEditing = false
            presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .Camera
            picker.delegate = self
            picker.allowsEditing = true
            picker.cameraFlashMode = .Off
            picker.showsCameraControls = true
            
            presentViewController(picker, animated: true, completion: nil)
        }
    }
        
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        if picker.sourceType == .Camera {
            let opencvImage = OpenCV.magicallyExtractChar(image)
            let transparentImage = SimpleImageProcessor.makeTransparent(opencvImage.CGImage!)
            handwrittingImage = transparentImage
            makeRoomForImage(handwrittingImageView)
        } else {
            backgroundImage = image
            makeRoomForImage(backgroundImageView)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func makeRoomForImage(imageView: UIImageView?) {
        if let charImageView = imageView {
            var extraHeight: CGFloat = 0
            if charImageView.image?.aspectRatio > 0 {
                if let width = charImageView.superview?.frame.size.width {
                    let height = width / charImageView.image!.aspectRatio
                    extraHeight = height - charImageView.frame.height
                    charImageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
                }
            } else {
                extraHeight = -charImageView.frame.height
                charImageView.frame = CGRectZero
            }
            preferredContentSize = CGSize(width: preferredContentSize.width, height: preferredContentSize.height + extraHeight)
        }
    }
    
    @IBAction func rotateHandWritting(sender: UIRotationGestureRecognizer) {
        if let imageView = handwrittingImageView {
            switch(sender.state) {
            case .Ended: fallthrough
            case .Changed:
                imageView.transform = CGAffineTransformRotate(imageView.transform, sender.rotation)
                sender.rotation = 0
            default: break
            }
        }
    }
    
    @IBAction func scaleHandwritting(sender: UIPinchGestureRecognizer) {
        if let imageView = handwrittingImageView {
            switch sender.state {
            case .Ended: fallthrough
            case .Changed:
                imageView.transform = CGAffineTransformScale(imageView.transform, sender.scale, sender.scale)
                sender.scale = 1
            default: break
            }
        }
    }
    
    @IBAction func flipHandwrittingColor(sender: UITapGestureRecognizer) {
        switch sender.state {
        case .Ended: fallthrough
        case .Changed:
            if let image = handwrittingImage {
                handwrittingImageView?.image = OpenCV.invertImage(image)
            }
        default: break
        }
    }
    
    private struct GestureScaleConstants {
        static let CharGestureScale: CGFloat = 2
    }
    
    @IBAction func moveHandwritting(sender: UIPanGestureRecognizer) {
        if let imageView = handwrittingImageView {
            switch sender.state {
            case .Ended: fallthrough
            case .Changed:
                let translation = sender.translationInView(imageView)
                imageView.transform = CGAffineTransformTranslate(imageView.transform, translation.x / GestureScaleConstants.CharGestureScale, translation.y / GestureScaleConstants.CharGestureScale)
                sender.setTranslation(CGPointZero, inView: imageView)
            default: break
            }
        }
    }

    
}

extension UIImage {
    var aspectRatio: CGFloat {
        return size.height != 0 ? size.width / size.height : 0
    }
}