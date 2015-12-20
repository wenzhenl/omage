//
//  ViewController.swift
//  Omage
//
//  Created by Wenzheng Li on 12/18/15.
//  Copyright © 2015 Wenzheng Li. All rights reserved.
//

import UIKit
import EasyTipView

class OmageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageCropViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, EasyTipViewDelegate {

    @IBOutlet weak var imageContainerView: UIView!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var foregroundImageView: UIImageView!
    
    @IBOutlet weak var tempImageView: UIImageView!
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBOutlet weak var bushSizeSlider: UISlider!
    
    @IBOutlet weak var thumbnailCollectionView: UICollectionView!
    
    @IBOutlet weak var backgroundButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var foregroundButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var eraserButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var cropperButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var saveOrShareButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var undoButtonItem: UIBarButtonItem!
    
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
            saveOrShareButtonItem.enabled = !eraserDidSelected
        }
    }
    
    var thumbnailViewDidAppear: Bool { return !thumbnailCollectionView.hidden}
    
    var snapshotsOfForegroundImage: [UIImage] = []
    
    var copyOfBackground: UIImage?
    
    var firstLauch: Bool = true
    
    var timesShowingBackTip = 0
    
    var timesShowingForeTip = 0
    
    var timesShowingEraserTip = 0
    
    var timesShowingCropTip = 0
    
    var timesShowingUndoTip = 0
    
    var timesToShow = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.barTintColor = Settings.ColorForHeader
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.toolBar.tintColor = Settings.ColorForHeader
        
        self.imageContainerView.bringSubviewToFront(backgroundImageView)
        self.imageContainerView.bringSubviewToFront(foregroundImageView)
        self.imageContainerView.bringSubviewToFront(tempImageView)
        self.view.bringSubviewToFront(toolBar)
        self.foregroundImageView.multipleTouchEnabled = true
        self.foregroundImageView.exclusiveTouch = true
        
        self.bushSizeSlider.hidden = true
        self.thumbnailCollectionView.hidden = true
        
        self.saveOrShareButtonItem.enabled = false
        
        // MARK - easy tip configuration
        var preferences = EasyTipView.Preferences()
        
        preferences.font = UIFont(name: "Futura-Medium", size: 13)
        preferences.textColor = UIColor.whiteColor()
        preferences.bubbleColor = UIColor(hue:0.46, saturation:0.99, brightness:0.6, alpha:1)
        preferences.arrowPosition = EasyTipView.ArrowPosition.Top
        
        EasyTipView.setGlobalPreferences(preferences)
        
        firstLauch = NSUserDefaults.standardUserDefaults().boolForKey("FirstLauch")
        if firstLauch {
            print("First lauch")
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "FirstLauch")
        } else {
            print("Not first lauch")
        }
        firstLauch = true
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
                    saveOrShareButtonItem.enabled = true
                }
            } else {
                saveOrShareButtonItem.enabled = false
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
    
    // MARK - easy tip view delegate functions
    func easyTipViewDidDismiss(tipView: EasyTipView) {
        print("\(tipView) did dismiss!")
    }
    
    @IBAction func pickBackground(sender: UIBarButtonItem) {
        if firstLauch && timesShowingBackTip++ < timesToShow {
            EasyTipView.showAnimated(true, forItem: self.backgroundButtonItem, withinSuperview: nil, text: NSLocalizedString("Select an image from your photo library as the background image", comment: "Tip for background selection"), preferences: nil, delegate: nil)
        }
        
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
       
        if firstLauch && timesShowingForeTip++ < timesToShow {
            EasyTipView.showAnimated(true, forItem: self.foregroundButtonItem, withinSuperview: nil, text: NSLocalizedString("You can take a photo or select from your exsiting ones as the foreground", comment: "Tip for foreground selection"), preferences: nil, delegate: nil)
        }
        
        let foregroundSourceOptions = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        foregroundSourceOptions.addAction(UIAlertAction(
            title: NSLocalizedString("Take photo", comment: "take photo"),
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
            title: NSLocalizedString("Select from photo library", comment: ""),
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
        foregroundSourceOptions.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil))
        
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
                foregroundImageView.image = ImageCutoutFilter.changeImageColor(foregroundImage, color: Settings.avaiableHandwrittingColors[currentColorIndex])
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
            let alert = UIAlertController(title: nil, message: NSLocalizedString("Delete foreground image?", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Delete", comment: ""),
                style: .Destructive)
                { (action: UIAlertAction) -> Void in
                    self.foregroundImage = nil
                }
            )
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func eraserDidSelected(sender: UIBarButtonItem) {
        
        if firstLauch && timesShowingEraserTip++ < timesToShow {
            EasyTipView.showAnimated(true, forItem: self.eraserButtonItem, withinSuperview: nil, text: NSLocalizedString("After you selected the foreground image, you can remove the noise here", comment: ""), preferences: nil, delegate: nil)
        }
        
        if foregroundImage != nil && !thumbnailViewDidAppear {
            eraserDidSelected = !eraserDidSelected
            foregroundImageView.transform = CGAffineTransformIdentity
            if eraserDidSelected {
                backgroundImage = nil
                self.title = NSLocalizedString("Editing", comment: "")
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
        if firstLauch && timesShowingCropTip++ < timesToShow {
            EasyTipView.showAnimated(true, forItem: self.cropperButtonItem, withinSuperview: nil, text: NSLocalizedString("When you have both your back- and fore- ground images ready, you can crop into your desired image here", comment:""), preferences: nil, delegate: nil)
        }
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

    // MARK - clip a region of view into an image
    func clipImageForRect(clipRect: CGRect, inView: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(clipRect.size, false, CGFloat(0.0))
        let ctx = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(ctx, -clipRect.origin.x, -clipRect.origin.y)
        inView.layer.renderInContext(ctx!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
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
        if firstLauch && timesShowingEraserTip++ < timesToShow {
            EasyTipView.showAnimated(true, forItem: self.undoButtonItem, withinSuperview: nil, text: NSLocalizedString("Undo the erase operation", comment: ""), preferences: nil, delegate: nil)
        }

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
    var effectDescriptions: [String] = []
    
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
        effectDescriptions.append(NSLocalizedString("Original", comment: ""))
        
        let designateColorImage = ImageCutoutFilter.cutImageOutWithColor(image, color: Settings.avaiableHandwrittingColors[0])
        thumbnailsOfForegroundEffects.append(designateColorImage!)
        effectsForForeground.append(.DesignateColor)
        effectDescriptions.append(NSLocalizedString("B&W", comment: ""))
        
        let designateColorInvertImage = ImageCutoutFilter.cutImageOutWithColorInverted(image, color: Settings.avaiableHandwrittingColors[0])
        thumbnailsOfForegroundEffects.append(designateColorInvertImage!)
        effectsForForeground.append(.DesignateColorInvert)
        effectDescriptions.append(NSLocalizedString("B&W Inverted", comment: ""))
        
        let originalColorImage = ImageCutoutFilter.cutImageOutOriginalColor(image)
        thumbnailsOfForegroundEffects.append(originalColorImage!)
        effectsForForeground.append(.OriginalColor)
        effectDescriptions.append(NSLocalizedString("Original Color", comment: ""))
        
        let originalColorInvertImage = ImageCutoutFilter.cutImageOutOriginalColorInverted(image)
        thumbnailsOfForegroundEffects.append(originalColorInvertImage!)
        effectsForForeground.append(.OriginalColorInvert)
        effectDescriptions.append(NSLocalizedString("Original Color Inverted", comment: ""))
        
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
        snapshotsOfForegroundImage = []
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumbnailsOfForegroundEffects.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Thumbnail collection cell", forIndexPath: indexPath) as! ThumbnailCollectionViewCell
        cell.thumbnail = thumbnailsOfForegroundEffects[indexPath.row]
        cell.backgroundColor = UIColor(patternImage: UIImage(named: "transparent")!)
        cell.effectLabel.text = effectDescriptions[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Thumbnail collection footer", forIndexPath: indexPath) as! ThumbnailFooterCollectionReusableView
            footerView.footerLabel.text = NSLocalizedString("Choose an effect", comment: "")
            return footerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    @IBAction func saveAndShare(sender: UIBarButtonItem) {
        if backgroundImage != nil {
            if foregroundImage != nil {
                let snapshotToSave = clipImageForRect(backgroundImageView.frame, inView: imageContainerView)
                UIImageWriteToSavedPhotosAlbum(snapshotToSave!, nil, nil, nil)
            } else {
                UIImageWriteToSavedPhotosAlbum(backgroundImage!, nil, nil, nil)
            }
            
            EasyTipView.showAnimated(true, forItem: self.saveOrShareButtonItem, withinSuperview: nil, text: NSLocalizedString("Successfully saved!", comment: ""), preferences: nil, delegate: nil)
        }
    }
}

extension UIImage {
    var aspectRatio: CGFloat {
        return size.height != 0 ? size.width / size.height : 0
    }
}

