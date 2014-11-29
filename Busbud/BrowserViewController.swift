//
//  BBBrowserViewController.swift
//  Busbud
//
//  Created by Romain Pouclet on 2014-11-29.
//  Copyright (c) 2014 Romain Pouclet. All rights reserved.
//

import UIKit

class BrowserViewController: UIViewController {

    @IBOutlet weak var browser: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        browser.loadRequest(NSURLRequest(URL: NSURL(string: "http://busbud.com")!));
    }
}
