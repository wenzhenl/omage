//
//  PositionViewController.swift
//  Omage
//
//  Created by Wenzheng Li on 4/9/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class PositionViewController: UIViewController {
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var fgImageView: UIImageView!
    
    @IBOutlet weak var containerView: UIView!
    
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
        
//        if !ImageData.vectorized && !ImageData.hasRequested {
//            sendHandwriting()
//            ImageData.hasRequested = true
//        }
        
        fgImage = ImageData.fgImage
        fgImageView.transform = ImageData.fgTransform
        
        if !ImageData.hasSeenPosTutorial {
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
        if !ImageData.hasSeenPosTutorial {
            let tip = self.storyboard?.instantiateViewControllerWithIdentifier(ImageData.IdentifierForTipViewController) as! TipViewController
            tip.message = "Now you can adjust the position of your handwriting. You can move, scale or rotate it with your fingers."
            tip.modalPresentationStyle = .OverFullScreen
            
            let center = NSNotificationCenter.defaultCenter()
            
            center.addObserver(self, selector: #selector(BGViewController.userKnows(_:)), name: ImageData.NameOfNotificationUserKnows, object: nil)
            
            self.presentViewController(tip, animated: true, completion: nil)
        }
    }
    
    func userKnows(notification: NSNotification) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ImageData.NameOfNotificationUserKnows, object: nil)
        self.dismissViewControllerAnimated(true) {
            ImageData.hasSeenPosTutorial = true
            self.blurView.removeFromSuperview()
        }
    }

    func sendHandwriting() {
        let params = NSMutableDictionary()

        let imageData = UIImageJPEGRepresentation(ImageData.fgImage!, 1.0)
        let base64String = imageData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
//        print(base64String)
        params["image"] = [ "content_type": "image/jpeg", "filename":"test.jpg", "file_data": base64String]
        
        let message = "Network Error"
        ImageData.fetchDataFromServer(self, errMsgForNetwork: message, destinationURL: ImageData.API, params: params, retrivedJSONHandler: handleServerResponse)
    }
    
    func handleServerResponse (json: NSDictionary?) {
        if let parseJSON = json {
            if let success = parseJSON["success"] as? Bool {
                print("get vectorized image success ",  success)
                if let message = parseJSON["message"] as? String {
                    print("get vectorized message: ", message)
                    
                    if success {
                        if let imageString = parseJSON["image"] as? String {
                            if let imageData = NSData(base64EncodedString: imageString, options: []) {

                                let vectorImage = UIImage(data: imageData)
                                self.fgImage = vectorImage
                                ImageData.vectorized = true
                                ImageData.fgImage = vectorImage
                                print("new image here")
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK - gestures handlers
    @IBAction func rotateHandWritting(sender: UIRotationGestureRecognizer) {
        if let imageView = fgImageView {
            switch(sender.state) {
            case .Ended: fallthrough
            case .Changed:
                imageView.transform = CGAffineTransformRotate(imageView.transform, sender.rotation)
                ImageData.fgTransform = imageView.transform
                sender.rotation = 0
            default: break
            }
        }
    }

    @IBAction func scaleHandwritting(sender: UIPinchGestureRecognizer) {
        if let imageView = fgImageView {
            switch sender.state {
            case .Ended: fallthrough
            case .Changed:
                imageView.transform = CGAffineTransformScale(imageView.transform, sender.scale, sender.scale)
                ImageData.fgTransform = imageView.transform
                sender.scale = 1
            default: break
            }
        }
    }

    @IBAction func moveHandwritting(sender: UIPanGestureRecognizer) {
        if let imageView = fgImageView {
            switch sender.state {
            case .Ended: fallthrough
            case .Changed:
                let translation = sender.translationInView(imageView)
                imageView.transform = CGAffineTransformTranslate(imageView.transform, translation.x / ImageData.GestureScaleForMovingHandwritting, translation.y / ImageData.GestureScaleForMovingHandwritting)
                ImageData.fgTransform = imageView.transform
                sender.setTranslation(CGPointZero, inView: imageView)
            default: break
            }
        }
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