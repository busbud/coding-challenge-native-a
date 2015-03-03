//
//  WebViewViewController.swift
//  Busbud-Challenge
//
//  Created by Julien Saad on 2015-03-03.
//  Copyright (c) 2015 Julien Saad. All rights reserved.
//

import UIKit
import MBProgressHUD

class WebViewViewController: BusbudViewController {
    
    var originCity: City!
    var destinationCity: City!
    var user: User!
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var closeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)

        let routeRequest = Router.WebView(lang: user.language, originUrl: originCity.url, destUrl: destinationCity.url)
        self.webView.scrollView.bounces = false
        self.webView.loadRequest(routeRequest.URLRequest)
        self.webView.delegate = self

    }

    @IBAction func closeButtonTapped(sender: AnyObject) {
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        closeButton.layer.backgroundColor = BusbudConstants.blueColor.CGColor
        closeButton.layer.cornerRadius = closeButton.frame.size.width/2
        closeButton.layer.shadowColor = UIColor.blackColor().CGColor
        closeButton.layer.shadowRadius = 3.0
        closeButton.layer.shadowOffset = CGSizeMake(1, 1)
        closeButton.layer.shadowOpacity = 0.3
    }
    
}

// MARK: UIWebViewDelegate
extension WebViewViewController: UIWebViewDelegate {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        _loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        _loadingNotification.mode = MBProgressHUDModeIndeterminate
        _loadingNotification.labelText = "Getting ticket options!"
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
}
