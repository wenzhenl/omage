//
//  BGViewController.swift
//  Omage
//
//  Created by Wenzheng Li on 4/9/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class BGViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
    
    var blurView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        image = ImageData.bgImage
        if !ImageData.hasSeenBGTutorial {
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
        if !ImageData.hasSeenBGTutorial {
            let tip = self.storyboard?.instantiateViewControllerWithIdentifier(ImageData.IdentifierForTipViewController) as! TipViewController
            tip.message = "As the first step, please choose a background image you want to add your handwriting on. You can choose from photo library or take a fresh image now. If you just want to use the demo image, click Next."
            tip.modalPresentationStyle = .OverFullScreen
            
            let center = NSNotificationCenter.defaultCenter()
            
            center.addObserver(self, selector: #selector(BGViewController.userKnows(_:)), name: ImageData.NameOfNotificationUserKnows, object: nil)
            
            self.presentViewController(tip, animated: true, completion: nil)
        }
    }

    func userKnows(notification: NSNotification) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ImageData.NameOfNotificationUserKnows, object: nil)
        self.dismissViewControllerAnimated(true) {
            ImageData.hasSeenBGTutorial = true
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
        self.image = image
        ImageData.bgImage = image
        dismissViewControllerAnimated(true) {
            self.performSegueWithIdentifier(ImageData.segueIdentifierToForeground, sender: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == ImageData.segueIdentifierToForeground {
                var destination = segue.destinationViewController
                // this next if-statement makes sure the segue prepares properly even
                //   if the MVC we're seguing to is wrapped in a UINavigationController
                if let navCon = destination as? UINavigationController {
                    destination = navCon.visibleViewController!
                }
                if let _ = destination as? FGViewController {
                    print("go to foreground")
                }
            }
        }
    }
}
