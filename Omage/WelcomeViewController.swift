//
//  ViewController.swift
//  Omage
//
//  Created by Wenzheng Li on 4/9/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func begin(sender: UIButton) {
        ImageData.hasSeenWelcomeTutorial = true
        let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        let initialViewController = self.storyboard!.instantiateViewControllerWithIdentifier(ImageData.IdentifierForBGViewController)
        appDelegate.window?.rootViewController = initialViewController
        appDelegate.window?.makeKeyAndVisible()
    }

}

