//
//  WebViewViewController.swift
//  Busbud-Challenge
//
//  Created by Julien Saad on 2015-03-03.
//  Copyright (c) 2015 Julien Saad. All rights reserved.
//

import UIKit

class WebViewViewController: UIViewController {
    
    var originCity: City!
    var destinationCity: City!
    var user: User!
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var closeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        let routeRequest = Router.WebView(lang: user.language, originUrl: originCity.url, destUrl: destinationCity.url)
        
        self.webView.loadRequest(routeRequest.URLRequest)

    }

    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
