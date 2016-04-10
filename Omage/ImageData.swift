//
//  ImageData.swift
//  Omage
//
//  Created by Wenzheng Li on 4/8/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation
import UIKit

class ImageData {
    // MARK - parameters for gestures
    static let GestureScaleForMovingHandwritting = CGFloat(2.0)
    
    static var bgImage : UIImage? = UIImage(named: "example_bg")
    static var fgImage : UIImage? = UIImage(named: "example_fg")
    static var vectorized: Bool = false
    static var hasRequested: Bool = false
    
    static let segueIdentifierToForeground = "go to fg"
    static let segueIdentifierToPosition = "go to position"
    
    static var fgTransform: CGAffineTransform = CGAffineTransformIdentity
    static var fgColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)

    // MARK - parameters for color
    static let avaiableHandwrittingColors =
        [   UIColor(red: 1.0, green: 153.0/255.0, blue: 51/255.0, alpha: 1.0),
            UIColor(red: 0, green: 0, blue: 0, alpha: 1.0),
            UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
            UIColor(red: 0.0078, green: 0.517647, blue: 0.5098039, alpha: 1.0),
            UIColor(red: 0, green: 0.4, blue: 0.6, alpha: 1.0),
            UIColor(red: 1.0, green: 0.4, blue: 0, alpha: 1.0)
    ]
    
    static let ColorOfAlertView = UIColor(red: 0.0078, green: 0.517647, blue: 0.5098039, alpha: 1.0)
    static let WidthOfCustomizedAlertView = CGFloat(280.0)
    static let HeightOfCustomizedAlertView = CGFloat(50.0)
    static let VerticalOffsetOfCustomizedAlertView = CGFloat(200.0)
    
    static let IdentifierForCustomizedAlertViewController = "Customized Alert View Controller"
    
    static func popupCustomizedAlert(viewController: UIViewController, message: String) {
        let customizedAlert = viewController.storyboard?.instantiateViewControllerWithIdentifier(IdentifierForCustomizedAlertViewController) as! CustomizedAlertViewController
        customizedAlert.message = message
//        customizedAlert.modalTransitionStyle = .CoverVertical
        customizedAlert.modalPresentationStyle = .OverFullScreen
        
        viewController.presentViewController(customizedAlert, animated: true, completion: nil)
        
        let delay = 2.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            viewController.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    // MARK - interaction with the server
    static let serverIP = "http://ec2-52-69-172-155.ap-northeast-1.compute.amazonaws.com/Handsome/"
    static let API = "fetch_vectorized_image.php"
    
    static func fetchDataFromServer(viewController: UIViewController, errMsgForNetwork: String, destinationURL: String, params: NSDictionary, retrivedJSONHandler: (NSDictionary?) -> Void) {
        
        if !NetworkAvailability.isConnectedToNetwork() {
            
            // Notify users there's error with network
            popupCustomizedAlert(viewController, message: errMsgForNetwork)
        } else {
            
            let url = serverIP + destinationURL
            print(url)
            
            let request = NSMutableURLRequest(URL: NSURL(string: url)!)
            let session = NSURLSession.sharedSession()
            request.HTTPMethod = "POST"
            
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions(rawValue: 0))
            }  catch  {
                print(error)
            }
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    var err: NSError?
                    var json:NSDictionary?
                    do{
                        json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    }catch{
                        print(error)
                        err = error as NSError
                    }
                    
                    // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                    if(err != nil) {
                        print("Response: \(response)")
                        let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        print("Body: \(strData!)")
                        print(err!.localizedDescription)
                        let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        print("Error could not parse JSON: '\(jsonStr)'")
                    } else {
                        retrivedJSONHandler(json)
                    }
                }
            })
            
            task.resume()
            print("data sent")
        }
    }
}