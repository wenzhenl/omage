//
//  ColorViewController.swift
//  Omage
//
//  Created by Wenzheng Li on 4/9/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class ColorViewController: UIViewController {
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var fgImageView: UIImageView!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var colorPanelView: UIView!

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
        
        let colorViewWidth = colorPanelView.frame.width
        let offsetToTop = CGFloat(40)
        
        for i in 0..<ImageData.avaiableHandwrittingColors.count {
            let colorViewRect = CGRectMake(0, offsetToTop + colorViewWidth * CGFloat(i), colorViewWidth, colorViewWidth)
            let colorView = UIButton(frame: colorViewRect)
            colorView.backgroundColor = ImageData.avaiableHandwrittingColors[i]
            colorView.layer.borderWidth = 4
            colorView.contentMode = .Redraw
            colorView.addTarget(self, action: #selector(self.setColor(_:)), forControlEvents: .TouchUpInside)
            self.colorPanelView.addSubview(colorView)
        }
        self.view.bringSubviewToFront(self.colorPanelView)
        
        if !ImageData.hasSeenColorTutorial {
            let blurEffect = UIBlurEffect(style: .ExtraLight)
            blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = view.bounds
            view.addSubview(blurView)
            view.bringSubviewToFront(blurView)
        }
    }
    
    @IBAction func moveColorPanel(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .Ended:
            fallthrough
        case .Changed:
            let translation = sender.translationInView(self.view)
            self.colorPanelView.center = CGPointMake(colorPanelView.center.x + translation.x/2, colorPanelView.center.y + translation.y/2)
            sender.setTranslation(CGPointZero, inView: view)
        default:
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if !ImageData.hasSeenColorTutorial {
            let tip = self.storyboard?.instantiateViewControllerWithIdentifier(ImageData.IdentifierForTipViewController) as! TipViewController
            tip.message = NSLocalizedString("You can also choose your favoriate color of your handwriting to best fit your background image. Move the color panel if it blocks your sight. ", comment:"")
            tip.modalPresentationStyle = .OverFullScreen
            
            let center = NSNotificationCenter.defaultCenter()
            
            center.addObserver(self, selector: #selector(BGViewController.userKnows(_:)), name: ImageData.NameOfNotificationUserKnows, object: nil)
            
            self.presentViewController(tip, animated: true, completion: nil)
        }
    }
    
    func userKnows(notification: NSNotification) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ImageData.NameOfNotificationUserKnows, object: nil)
        self.dismissViewControllerAnimated(true) {
            ImageData.hasSeenColorTutorial = true
            self.blurView.removeFromSuperview()
        }
    }

    func setColor(sender: UIButton) {
        print(sender.backgroundColor)
        fgImage = ImageCutoutFilter.changeImageColor(ImageData.fgImage, color: sender.backgroundColor)
        ImageData.fgImage = self.fgImage
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