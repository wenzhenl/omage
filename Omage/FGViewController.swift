//
//  FGViewController.swift
//  Omage
//
//  Created by Wenzheng Li on 4/9/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class FGViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var fgImageView: UIImageView!
    
    var blurView: UIView!

    var bgImage: UIImage? {
        get {
            return bgImageView.image
        }
        set {
            bgImageView.image = newValue
        }
    }
    
    var fgImage: UIImage? {
        get {
            return fgImageView.image
        }
        set {
            fgImageView.image = newValue
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        bgImage = ImageData.bgImage
        fgImage = ImageData.fgImage
        
        if !ImageData.hasSeenFGTutorial {
            let blurEffect = UIBlurEffect(style: .ExtraLight)
            blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = view.bounds
            view.addSubview(blurView)
            view.bringSubviewToFront(blurView)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if !ImageData.hasSeenFGTutorial {
            let tip = self.storyboard?.instantiateViewControllerWithIdentifier(ImageData.IdentifierForTipViewController) as! TipViewController
            tip.message = "Take a photo of your handwriting on the paper, pay attention to the lighting to make sure the shadow is smooth. Of course, you will try beautiful illustrations beyond your handwriting!"
            tip.modalPresentationStyle = .OverFullScreen
            
            let center = NSNotificationCenter.defaultCenter()
            
            center.addObserver(self, selector: #selector(BGViewController.userKnows(_:)), name: ImageData.NameOfNotificationUserKnows, object: nil)
            
            self.presentViewController(tip, animated: true, completion: nil)
        }
    }
    
    func userKnows(notification: NSNotification) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ImageData.NameOfNotificationUserKnows, object: nil)
        self.dismissViewControllerAnimated(true) {
            ImageData.hasSeenFGTutorial = true
            self.blurView.removeFromSuperview()
        }
    }
    
    @IBAction func showCamera(sender: UIButton) {
        print("show camera")
        let picker = UIImagePickerController()
        picker.sourceType = .Camera
        picker.delegate = self
        picker.allowsEditing = false
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func showPhotoLibrary() {
        print("show photo library")
        let picker = UIImagePickerController()
        picker.sourceType = .PhotoLibrary
        picker.delegate = self
        picker.allowsEditing = false
        picker.navigationBar.tintColor = UIColor.redColor()
        picker.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.redColor(), NSFontAttributeName: UIFont.systemFontOfSize(20)]
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        let opencvImage = OpenCV.magicallyExtractChar(image)
        let black = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        self.fgImage = ImageCutoutFilter.cutImageOutWithColor(opencvImage, color: black)
        ImageData.fgImage = self.fgImage
        ImageData.fgTransform = CGAffineTransformIdentity
        ImageData.vectorized = false
        ImageData.hasRequested = false
        dismissViewControllerAnimated(true) {
            self.performSegueWithIdentifier(ImageData.segueIdentifierToPosition, sender: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
