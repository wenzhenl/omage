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
    
    @IBOutlet weak var colorButton: ColorButton!
    
    @IBOutlet weak var eraserButton: EraserButton!
    
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
                if handwrittingImageView != nil {
                    imageViewContainer.bringSubviewToFront(handwrittingImageView!)
                }
            }
        }
    }
    
    private var opencvImage: UIImage?
    private var isBlack: Bool = true

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
        self.view.bringSubviewToFront(colorButton)
        self.view.bringSubviewToFront(eraserButton)
        backgroundImage = UIImage(named: "example_background")
    }
    
    override func viewDidLayoutSubviews() {
        makeRoomForImage(backgroundImageView)
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
        
    
    @IBAction func setHandwrittingColor() {
        if handwrittingImageView == nil {
            let alert = UIAlertController(title: "无法选择颜色", message: "请先使用相机提取手写字句", preferredStyle: UIAlertControllerStyle.Alert)
            self.presentViewController(alert, animated: true, completion: nil)
            
            let delay = 1.5 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                alert.dismissViewControllerAnimated(true, completion: nil)
            })
        } else {
            let colorPanel = UIAlertController(title: "请选择手写字句的颜色", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
            colorPanel.addAction(UIAlertAction(
                title: "brown",
                style: .Default)
                { (action: UIAlertAction) -> Void in
                    self.handleHandwrittingColorChange(UIColor(red: 0.0078, green: 0.517647, blue: 0.5098039, alpha: 1.0))
                }
            )
            
            colorPanel.addAction(UIAlertAction(
                title: "brown",
                style: .Default)
                { (action: UIAlertAction) -> Void in
                   self.handleHandwrittingColorChange(UIColor(red: 0, green: 0.4, blue: 0.6, alpha: 1.0))
                }
            )
            
            colorPanel.addAction(UIAlertAction(
                title: "brown",
                style: .Default)
                { (action: UIAlertAction) -> Void in
                    self.handleHandwrittingColorChange(UIColor(red: 1.0, green: 0.4, blue: 0, alpha: 1.0))
                }
            )
            
            colorPanel.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
            self.presentViewController(colorPanel, animated: true, completion: nil)
        }
    }
    
    func handleHandwrittingColorChange(color: UIColor) {
        let transpatentImage = SimpleImageProcessor.makeTransparent((self.opencvImage?.CGImage)!, color: color.CGColor)
        let currentTransform = handwrittingImageView?.transform
        handwrittingImage = transpatentImage
        makeRoomForImage(handwrittingImageView)
        handwrittingImageView?.transform = currentTransform!
        
    }
    
    @IBAction func removeNoise() {
        eraserButton.flipState()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        if picker.sourceType == .Camera {
            opencvImage = OpenCV.magicallyExtractChar(image)
            let transparentImage = SimpleImageProcessor.makeTransparent(opencvImage!.CGImage!, color: UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).CGColor)
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
            if handwrittingImage != nil {
                if isBlack {
                    handwrittingImageView!.image = SimpleImageProcessor.makeTransparent((opencvImage?.CGImage)!, color: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).CGColor)
                } else {
                    handwrittingImageView!.image = SimpleImageProcessor.makeTransparent((opencvImage?.CGImage)!, color: UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).CGColor)
                }
                isBlack = !isBlack
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

    @IBAction func share() {
        let savingImage = clipImageForRect((backgroundImageView?.bounds)!, inView: imageViewContainer)
        UIImageWriteToSavedPhotosAlbum(savingImage!, nil, nil, nil)
        // Notify users saved successfully
        let alert = UIAlertController(title: nil, message: "Saved successfully!", preferredStyle: UIAlertControllerStyle.Alert)
        self.presentViewController(alert, animated: true, completion: nil)
        
        let delay = 1.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            alert.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    // MARK - clip a region of view into an image
    func clipImageForRect(clipRect: CGRect, inView: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(clipRect.size, false, CGFloat(1.0))
        let ctx = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(ctx, -clipRect.origin.x, -clipRect.origin.y)
        inView.layer.renderInContext(ctx!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
}

extension UIImage {
    var aspectRatio: CGFloat {
        return size.height != 0 ? size.width / size.height : 0
    }
}