//
//  WebViewController.swift
//  Smashtag
//
//  Created by Wenzheng Li on 9/20/15.
//  Copyright © 2015 Wenzheng Li. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var menuButtonItem: UIBarButtonItem!
    
    var url: NSURL? {
        didSet {
            if view.window != nil {
                loadURL()
            }
        }
    }
    
    private func loadURL() {
        if url != nil {
            webView.loadRequest(NSURLRequest(URL: url!))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.barTintColor = Settings.ColorForHeader
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(20)]
        
//        self.view.bringSubviewToFront(spinner)
        
        if self.revealViewController() != nil {
            menuButtonItem.target = self.revealViewController()
            menuButtonItem.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        webView.delegate = self
        webView.scalesPageToFit = true
        
        if let pdf = NSBundle.mainBundle().URLForResource("ThirdPartyLicenses", withExtension: "html", subdirectory: nil, localization: nil) {
            url = pdf
            print("good")
        }
        
        loadURL()

        // Do any additional setup after loading the view.
    }

    // MARK: - UIWebView delegate
    
    var activeDownloads = 0
    
    func webViewDidStartLoad(webView: UIWebView) {
        activeDownloads++
        spinner.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activeDownloads--
        if activeDownloads < 1 {
            spinner.stopAnimating()
//            spinner.removeFromSuperview()
        }
    }
}
