//
//  ColorViewController.swift
//  Omage
//
//  Created by Wenzheng Li on 4/9/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class ShareViewController: UIViewController {
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var fgImageView: UIImageView!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var mergedImageView: UIView!
    
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
        fgImageView.multipleTouchEnabled = true
        fgImageView.exclusiveTouch = true
        
        bgImage = ImageData.bgImage
        fgImage = ImageData.fgImage
        
        fgImageView.transform = ImageData.fgTransform
        
        if !ImageData.hasSeenShareTutorial {
            let blurEffect = UIBlurEffect(style: .ExtraLight)
            blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = view.bounds
            view.addSubview(blurView)
            view.bringSubviewToFront(blurView)
        }
    }
    
    @IBAction func saveImage(sender: UIButton) {
        let mergedImage = clipImageForRect(mergedImageView.frame, inView: mergedImageView)!
        let pngImage = UIImagePNGRepresentation(mergedImage)
        let savedImage = UIImage(data: pngImage!)
        UIImageWriteToSavedPhotosAlbum(savedImage!, nil, nil, nil)
        ImageData.popupCustomizedAlert(self, message: "Saved!")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if !ImageData.hasSeenShareTutorial {
            let tip = self.storyboard?.instantiateViewControllerWithIdentifier(ImageData.IdentifierForTipViewController) as! TipViewController
            tip.message = "Congratulations! You just create an image with your particular handwriting. You can save it to your photo library and share it to whereever you want."
            tip.modalPresentationStyle = .OverFullScreen
            
            let center = NSNotificationCenter.defaultCenter()
            
            center.addObserver(self, selector: #selector(BGViewController.userKnows(_:)), name: ImageData.NameOfNotificationUserKnows, object: nil)
            
            self.presentViewController(tip, animated: true, completion: nil)
        }
    }
    
    func userKnows(notification: NSNotification) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ImageData.NameOfNotificationUserKnows, object: nil)
        self.dismissViewControllerAnimated(true) {
            ImageData.hasSeenShareTutorial = true
            self.blurView.removeFromSuperview()
        }
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
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}