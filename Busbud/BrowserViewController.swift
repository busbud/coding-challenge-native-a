//
//  BBBrowserViewController.swift
//  Busbud
//
//  Created by Romain Pouclet on 2014-11-29.
//  Copyright (c) 2014 Romain Pouclet. All rights reserved.
//

import UIKit

@objc class BrowserViewController: UIViewController {

    @IBOutlet weak var browser: UIWebView!
    var url: NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        browser.loadRequest(NSURLRequest(URL: url));
    }
}
