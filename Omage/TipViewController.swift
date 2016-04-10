//
//  TipViewController.swift
//  Omage
//
//  Created by Wenzheng Li on 4/10/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import UIKit

class TipViewController: UIViewController {
    var message: String! = "Please haha"
    
    @IBOutlet weak var tipLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tipLabel.text = message
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func confirm(sender: UIButton) {
        NSNotificationCenter.defaultCenter().postNotificationName(ImageData.NameOfNotificationUserKnows, object: nil, userInfo: nil)
//        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
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
