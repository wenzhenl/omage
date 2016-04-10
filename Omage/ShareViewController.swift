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