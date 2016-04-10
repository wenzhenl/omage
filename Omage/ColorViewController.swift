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
        fgImage = ImageCutoutFilter.cutImageOutWithColor(ImageData.fgImage, color: ImageData.fgColor)
        
        fgImageView.transform = ImageData.fgTransform
        
        let colorViewWidth = colorPanelView.frame.width
        for i in 0..<ImageData.avaiableHandwrittingColors.count {
            let colorViewRect = CGRectMake(0, colorViewWidth * CGFloat(i), colorViewWidth, colorViewWidth)
            let colorView = UIButton(frame: colorViewRect)
            colorView.backgroundColor = ImageData.avaiableHandwrittingColors[i]
            colorView.layer.borderWidth = 4
            colorView.contentMode = .Redraw
            colorView.addTarget(self, action: #selector(self.setColor(_:)), forControlEvents: .TouchUpInside)
            self.colorPanelView.addSubview(colorView)
        }
        self.view.bringSubviewToFront(self.colorPanelView)
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
    
    func setColor(sender: UIButton) {
        print(sender.backgroundColor)
        fgImage = ImageCutoutFilter.cutImageOutWithColor(ImageData.fgImage, color: sender.backgroundColor)
        ImageData.fgColor = sender.backgroundColor!
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