//
//  ViewController.swift
//  Omage
//
//  Created by Wenzheng Li on 12/18/15.
//  Copyright © 2015 Wenzheng Li. All rights reserved.
//

import UIKit

class OmageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageCropViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var imageContainerView: UIView!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var foregroundImageView: UIImageView!
    
    @IBOutlet weak var tempImageView: UIImageView!
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBOutlet weak var bushSizeSlider: UISlider!
    
    @IBOutlet weak var thumbnailCollectionView: UICollectionView!
    
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    @IBOutlet var pinchGesture: UIPinchGestureRecognizer!
    
    @IBOutlet var rotationGesture: UIRotationGestureRecognizer!
    
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    
    @IBOutlet var longPressGesture: UILongPressGestureRecognizer!
    
    var photoForBackground = true
    
    var eraserDidSelected = false {
        didSet {
            tapGesture.enabled = !eraserDidSelected
            pinchGesture.enabled = !eraserDidSelected
            rotationGesture.enabled = !eraserDidSelected
            panGesture.enabled = !eraserDidSelected
            longPressGesture.enabled = !eraserDidSelected
        }
    }
    
    var thumbnailViewDidAppear: Bool { return !thumbnailCollectionView.hidden}
    
    var snapshotsOfForegroundImage: [UIImage] = []
    
    var copyOfBackground: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.barTintColor = Settings.ColorForHeader
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.imageContainerView.bringSubviewToFront(backgroundImageView)
        self.imageContainerView.bringSubviewToFront(foregroundImageView)
        self.imageContainerView.bringSubviewToFront(tempImageView)
        self.view.bringSubviewToFront(toolBar)
        self.foregroundImageView.multipleTouchEnabled = true
        self.foregroundImageView.exclusiveTouch = true
        
        self.bushSizeSlider.hidden = true
        self.thumbnailCollectionView.hidden = true
    }
    
    // MARK - background image
    private var backgroundImage: UIImage? {
        get { return backgroundImageView?.image }
        set {
            backgroundImageView.image = newValue
            if backgroundImage != nil {
                if backgroundImageView.bounds.width > backgroundImage!.size.width && backgroundImageView.bounds.height > backgroundImage!.size.height {
                    print("Center")
                    backgroundImageView.contentMode = .Center
                } else {
                    print("AspectFit")
                    backgroundImageView.contentMode = .ScaleAspectFit
                }
            }
//            imageContainerView.bringSubviewToFront(foregroundImageView)
//            imageContainerView.bringSubviewToFront(tempImageView)
        }
    }
    
    // MARK - foreground image
    
    private var foregroundImage: UIImage? {
        get { return foregroundImageView?.image }
        set {
            foregroundImageView.image = newValue
            foregroundImageView.transform = CGAffineTransformIdentity
            if foregroundImage != nil {
                if foregroundImageView.bounds.width > foregroundImage!.size.width && foregroundImageView.bounds.height > foregroundImage!.size.height {
                    print("Center")
                    foregroundImageView.contentMode = .Center
                } else {
                    print("AspectFit")
                    foregroundImageView.contentMode = .ScaleAspectFit
                }
            } else {
                snapshotsOfForegroundImage = []
            }
            
//            self.imageContainerView.bringSubviewToFront(foregroundImageView)
//            self.imageContainerView.bringSubviewToFront(tempImageView)
        }
    }
    
    @IBAction func pickBackground(sender: UIBarButtonItem) {
        photoForBackground = true
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            let picker = UIImagePickerController()
            picker.sourceType = .PhotoLibrary
            picker.allowsEditing = false
            picker.delegate = self
            presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func pickForeground(sender: UIBarButtonItem) {
        let foregroundSourceOptions = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        foregroundSourceOptions.addAction(UIAlertAction(
            title: "Take photo",
            style: .Default)
            { (action:UIAlertAction) -> Void in
                if UIImagePickerController.isSourceTypeAvailable(.Camera) {
                    let picker = UIImagePickerController()
                    picker.sourceType = .Camera
                    picker.delegate = self
                    picker.allowsEditing = true
                    picker.cameraFlashMode = .Off
                    picker.showsCameraControls = true
                    
                    self.presentViewController(picker, animated: true, completion: nil)
                }
            })
        
        foregroundSourceOptions.addAction(UIAlertAction(
            title: "Select from photo library",
            style: .Default)
            { (action:UIAlertAction) -> Void in
                self.photoForBackground = false
                if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
                    let picker = UIImagePickerController()
                    picker.sourceType = .PhotoLibrary
                    picker.delegate = self
                    picker.allowsEditing = false
                    self.presentViewController(picker, animated: true, completion: nil)
                }
            })
        foregroundSourceOptions.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(foregroundSourceOptions, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        if picker.sourceType == .Camera {
            prepareThumbnailsForForegroundEffects(image!)
        } else {
            if photoForBackground {
                backgroundImage = image
                copyOfBackground = image
            } else {
                prepareThumbnailsForForegroundEffects(image!)
            }
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK - gestures handlers
    @IBAction func rotateHandWritting(sender: UIRotationGestureRecognizer) {
        if let imageView = foregroundImageView {
            switch(sender.state) {
            case .Ended: fallthrough
            case .Changed:
                imageView.transform = CGAffineTransformRotate(imageView.transform, sender.rotation)
                sender.rotation = 0
                
//                 print(foregroundImageView.frame, foregroundImageView.bounds)
            default: break
            }
        }
    }
    
    @IBAction func scaleHandwritting(sender: UIPinchGestureRecognizer) {
        if let imageView = foregroundImageView {
            switch sender.state {
            case .Ended: fallthrough
            case .Changed:
                imageView.transform = CGAffineTransformScale(imageView.transform, sender.scale, sender.scale)
                sender.scale = 1
                
//                 print(foregroundImageView.frame, foregroundImageView.bounds)
            default: break
            }
        }
    }
    
    var currentColorIndex = 0
    
    @IBAction func changeHandwrittingColor(sender: UITapGestureRecognizer) {
        switch sender.state {
        case .Ended: fallthrough
        case .Changed:
            if foregroundImage != nil && (effectOfForeground == .DesignateColor || effectOfForeground == .DesignateColorInvert) {
                currentColorIndex = (currentColorIndex + 1) % Settings.avaiableHandwrittingColors.count
                if effectOfForeground == .DesignateColor {
                    foregroundImage = ImageCutoutFilter.cutImageOutWithColor(thumbnailsOfForegroundEffects[0], color: Settings.avaiableHandwrittingColors[currentColorIndex])
                }
                else if effectOfForeground == .DesignateColorInvert {
                    foregroundImage = ImageCutoutFilter.cutImageOutWithColorInverted(thumbnailsOfForegroundEffects[0], color: Settings.avaiableHandwrittingColors[currentColorIndex])
                }
            }
        default: break
        }
    }
    
    @IBAction func moveHandwritting(sender: UIPanGestureRecognizer) {
        if let imageView = foregroundImageView {
            switch sender.state {
            case .Ended: fallthrough
            case .Changed:
                let translation = sender.translationInView(imageView)
                imageView.transform = CGAffineTransformTranslate(imageView.transform, translation.x / Settings.GestureScaleForMovingHandwritting, translation.y / Settings.GestureScaleForMovingHandwritting)
                sender.setTranslation(CGPointZero, inView: imageView)
                
//                print(foregroundImageView.frame, foregroundImageView.bounds)
            default: break
            }
        }
    }
    
    @IBAction func bushSizeChanged(sender: UISlider) {
        brushWidth = CGFloat(sender.value)
    }
    
    @IBAction func deleteForeground(sender: UILongPressGestureRecognizer) {
        if foregroundImage != nil {
            let alert = UIAlertController(title: nil, message: "Delete foreground image?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(
                title: "Delete",
                style: .Destructive)
                { (action: UIAlertAction) -> Void in
                    self.foregroundImage = nil
                }
            )
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func eraserDidSelected(sender: UIBarButtonItem) {
        if foregroundImage != nil && !thumbnailViewDidAppear {
            eraserDidSelected = !eraserDidSelected
            foregroundImageView.transform = CGAffineTransformIdentity
            if eraserDidSelected {
                backgroundImage = nil
                self.title = "Editing"
                self.bushSizeSlider.hidden = false
                self.imageContainerView.bringSubviewToFront(bushSizeSlider)
                foregroundImageView.backgroundColor = UIColor(patternImage: UIImage(named: "transparent")!)
            } else {
                backgroundImage = copyOfBackground
                foregroundImageView.backgroundColor = UIColor.clearColor()
                self.title = "Omage"
                self.bushSizeSlider.hidden = true
                self.bushSizeSlider.value = 10
            }
        }
    }
    
    @IBAction func crop(sender: UIBarButtonItem) {
        if (backgroundImage != nil || foregroundImage != nil) && !eraserDidSelected && !thumbnailViewDidAppear {
            let combinedImage = ImageCutoutFilter.convertSnapshotToImage(saveUIViewAsUIImage(imageContainerView))
            
            let chopper = ImageCropViewController(image: combinedImage)
            chopper.blurredBackground = true
            chopper.delegate = self
            self.navigationController?.pushViewController(chopper, animated: true)
        }

    }
    
    func ImageCropViewControllerSuccess(controller: UIViewController!, didFinishCroppingImage croppedImage: UIImage!) {
        backgroundImage = croppedImage
        copyOfBackground = croppedImage
        foregroundImage = nil
        navigationController?.popViewControllerAnimated(true)
    }
    
    func ImageCropViewControllerDidCancel(controller: UIViewController!) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK - save an UIView as an UIImage
    func saveUIViewAsUIImage(view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false , CGFloat(0.0))
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    private var lastPoint = CGPoint.zero
    private var red: CGFloat = 1.0
    private var green: CGFloat = 1.0
    private var blue: CGFloat = 1.0
    private var brushWidth: CGFloat = 9.0
    private var opacity: CGFloat = 1.0
    private var swiped = false
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if eraserDidSelected && foregroundImage != nil {
            swiped = false
            if let touch = touches.first {
                lastPoint = touch.locationInView(tempImageView)
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if eraserDidSelected && foregroundImage != nil {
            swiped = true
            if let touch = touches.first {
                let currentPoint = touch.locationInView(tempImageView)
                drawLineFrom(lastPoint, toPoint: currentPoint)
                
                lastPoint = currentPoint
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if eraserDidSelected && foregroundImage != nil {
            if !swiped {
                drawLineFrom(lastPoint, toPoint: lastPoint)
            }
            
            // Merge tempImageView into foregroundImageView
            UIGraphicsBeginImageContext(foregroundImageView.frame.size)
            foregroundImageView.image?.drawInRect(getImageRectForImageView(foregroundImageView), blendMode: .Normal, alpha: 1.0)
            tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: foregroundImageView.frame.size.width, height: foregroundImageView.frame.size.height), blendMode: .Normal, alpha: opacity)
            foregroundImageView.image = ImageCutoutFilter.cutImageOut(UIGraphicsGetImageFromCurrentImageContext())
            UIGraphicsEndImageContext()
            
            snapshotsOfForegroundImage.append(foregroundImage!)

            tempImageView.image = nil
        }
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        UIGraphicsBeginImageContext(tempImageView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: tempImageView.frame.size.width, height: tempImageView.frame.size.height))
        print(tempImageView.frame.size.width, tempImageView.frame.size.height)
        // 2
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        // 3
        CGContextSetLineCap(context, .Square)
        CGContextSetLineWidth(context, brushWidth)
        CGContextSetRGBStrokeColor(context, red, green, blue, 1.0)
        CGContextSetBlendMode(context, .Normal)
        CGContextSetShouldAntialias(context, false)
        
        // 4
        CGContextStrokePath(context)
        
        // 5
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
    }
    
    func getImageRectForImageView(imageView: UIImageView) -> CGRect {
        let resVi = imageView.image!.size.width / imageView.image!.size.height
        let resPl = imageView.bounds.size.width / imageView.bounds.size.height
        
        if (resPl > resVi) {
            
            let imageSize = CGSizeMake(imageView.image!.size.width * imageView.bounds.size.height / imageView.image!.size.height, imageView.bounds.size.height)
            return CGRectMake((imageView.bounds.size.width - imageSize.width)/2,
                (imageView.bounds.size.height - imageSize.height)/2,
                imageSize.width,
                imageSize.height)
        } else {
            let imageSize = CGSizeMake(imageView.bounds.size.width, imageView.image!.size.height * imageView.bounds.size.width / imageView.image!.size.width)
            return CGRectMake((imageView.bounds.size.width - imageSize.width)/2,
                (imageView.bounds.size.height - imageSize.height)/2,
                imageSize.width,
                imageSize.height);
        }
    }
    
    @IBAction func undoErase(sender: UIBarButtonItem) {
        if eraserDidSelected {
            print("count", snapshotsOfForegroundImage.count)
            if snapshotsOfForegroundImage.count > 1 {
                foregroundImage = snapshotsOfForegroundImage.last
                snapshotsOfForegroundImage.removeLast()
            }
            else if snapshotsOfForegroundImage.count == 1 {
                foregroundImage = snapshotsOfForegroundImage.last
            }
        }
    }
    
    // MARK - delegate for UICollectionView
    var thumbnailsOfForegroundEffects: [UIImage] = []
    var effectsForForeground: [ForegroundEffect] = []
    var effectOfForeground: ForegroundEffect = .DesignateColor

    enum ForegroundEffect {
        case Original
        case OriginalColor
        case OriginalColorInvert
        case DesignateColor
        case DesignateColorInvert
    }
    
    func prepareThumbnailsForForegroundEffects(image: UIImage) {
        thumbnailsOfForegroundEffects = []
        effectsForForeground = []
        
        let originalImage = image
        thumbnailsOfForegroundEffects.append(originalImage)
        effectsForForeground.append(.Original)
        
        let originalColorImage = ImageCutoutFilter.cutImageOutOriginalColor(image)
        thumbnailsOfForegroundEffects.append(originalColorImage!)
        effectsForForeground.append(.OriginalColor)
        
        let originalColorInvertImage = ImageCutoutFilter.cutImageOutOriginalColorInverted(image)
        thumbnailsOfForegroundEffects.append(originalColorInvertImage!)
        effectsForForeground.append(.OriginalColorInvert)
        
        let designateColorImage = ImageCutoutFilter.cutImageOutWithColor(image, color: Settings.avaiableHandwrittingColors[0])
        thumbnailsOfForegroundEffects.append(designateColorImage!)
        effectsForForeground.append(.DesignateColor)
        
        let designateColorInvertImage = ImageCutoutFilter.cutImageOutWithColorInverted(image, color: Settings.avaiableHandwrittingColors[0])
        thumbnailsOfForegroundEffects.append(designateColorInvertImage!)
        effectsForForeground.append(.DesignateColorInvert)
        
        self.imageContainerView.bringSubviewToFront(thumbnailCollectionView)
        self.thumbnailCollectionView.hidden = false
        self.thumbnailCollectionView.reloadData()
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.row, " Selected")
        foregroundImage = thumbnailsOfForegroundEffects[indexPath.row]
        snapshotsOfForegroundImage = [foregroundImage!]
        self.thumbnailCollectionView.hidden = true
        effectOfForeground = effectsForForeground[indexPath.row]
//        snapshotsOfForegroundImage = []
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumbnailsOfForegroundEffects.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Thumbnail collection cell", forIndexPath: indexPath) as! ThumbnailCollectionViewCell
        cell.thumbnail = thumbnailsOfForegroundEffects[indexPath.row]
        cell.backgroundColor = UIColor(patternImage: UIImage(named: "transparent")!)
        return cell
    }
}

extension UIImage {
    var aspectRatio: CGFloat {
        return size.height != 0 ? size.width / size.height : 0
    }
}

